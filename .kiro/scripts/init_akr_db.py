#!/usr/bin/env python3
"""
init_akr_db.py - Initialize SQLite database for AKR

Purpose: Create SQLite database schema for efficient AKR queries

Usage:
    python3 init_akr_db.py [--force]

Options:
    --force    Drop existing database and recreate from scratch

Environment:
    GENERO_AKR_DB_PATH    Path to SQLite database (default: $BRODIR/etc/genero-akr/akr.db)
"""

import sqlite3
import os
import sys
import argparse
from pathlib import Path
from datetime import datetime

def get_db_path():
    """Get database path from environment or use default."""
    db_path = os.environ.get('GENERO_AKR_DB_PATH')
    if db_path:
        return db_path
    
    brodir = os.environ.get('BRODIR', '/opt/genero')
    return os.path.join(brodir, 'etc', 'genero-akr', 'akr.db')

def create_schema(conn):
    """Create database schema with all tables, indexes, and views."""
    cursor = conn.cursor()
    
    # Artifacts table: stores metadata about each artifact
    cursor.execute('''
        CREATE TABLE artifacts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            type TEXT NOT NULL CHECK(type IN ('function', 'module', 'file', 'pattern', 'issue')),
            path TEXT,
            status TEXT NOT NULL DEFAULT 'active' CHECK(status IN ('active', 'deprecated', 'archived')),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_by TEXT,
            UNIQUE(name, type)
        )
    ''')
    
    # Metrics table: code quality metrics
    cursor.execute('''
        CREATE TABLE metrics (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            artifact_id INTEGER NOT NULL UNIQUE,
            complexity INTEGER DEFAULT 0,
            lines_of_code INTEGER DEFAULT 0,
            parameter_count INTEGER DEFAULT 0,
            dependent_count INTEGER DEFAULT 0,
            return_count INTEGER DEFAULT 0,
            FOREIGN KEY(artifact_id) REFERENCES artifacts(id) ON DELETE CASCADE
        )
    ''')
    
    # Findings table: individual findings about artifacts
    cursor.execute('''
        CREATE TABLE findings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            artifact_id INTEGER NOT NULL,
            finding TEXT NOT NULL,
            priority TEXT DEFAULT 'MEDIUM' CHECK(priority IN ('LOW', 'MEDIUM', 'HIGH')),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(artifact_id) REFERENCES artifacts(id) ON DELETE CASCADE
        )
    ''')
    
    # Issues table: known issues and tool gaps
    cursor.execute('''
        CREATE TABLE issues (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            artifact_id INTEGER NOT NULL,
            issue_type TEXT NOT NULL,
            severity TEXT DEFAULT 'MEDIUM' CHECK(severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
            description TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(artifact_id) REFERENCES artifacts(id) ON DELETE CASCADE
        )
    ''')
    
    # Recommendations table: actionable recommendations
    cursor.execute('''
        CREATE TABLE recommendations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            artifact_id INTEGER NOT NULL,
            recommendation TEXT NOT NULL,
            priority TEXT DEFAULT 'MEDIUM' CHECK(priority IN ('LOW', 'MEDIUM', 'HIGH')),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(artifact_id) REFERENCES artifacts(id) ON DELETE CASCADE
        )
    ''')
    
    # Dependencies table: function call relationships
    cursor.execute('''
        CREATE TABLE dependencies (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            source_artifact_id INTEGER NOT NULL,
            target_artifact_id INTEGER NOT NULL,
            dependency_type TEXT DEFAULT 'calls' CHECK(dependency_type IN ('calls', 'called_by', 'imports', 'imported_by')),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(source_artifact_id) REFERENCES artifacts(id) ON DELETE CASCADE,
            FOREIGN KEY(target_artifact_id) REFERENCES artifacts(id) ON DELETE CASCADE
        )
    ''')
    
    # Audit trail table: action history for traceability
    cursor.execute('''
        CREATE TABLE audit_trail (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            action TEXT NOT NULL,
            artifact_id INTEGER,
            agent_id TEXT,
            details TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(artifact_id) REFERENCES artifacts(id) ON DELETE SET NULL
        )
    ''')
    
    # Staleness table: knowledge age tracking
    cursor.execute('''
        CREATE TABLE staleness (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            artifact_id INTEGER NOT NULL UNIQUE,
            status TEXT DEFAULT 'FRESH' CHECK(status IN ('FRESH', 'STALE', 'VERY_STALE')),
            days_since_update INTEGER DEFAULT 0,
            last_checked TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(artifact_id) REFERENCES artifacts(id) ON DELETE CASCADE
        )
    ''')
    
    # Create indexes for common queries
    cursor.execute('CREATE INDEX idx_artifacts_type ON artifacts(type)')
    cursor.execute('CREATE INDEX idx_artifacts_status ON artifacts(status)')
    cursor.execute('CREATE INDEX idx_artifacts_updated_at ON artifacts(updated_at)')
    cursor.execute('CREATE INDEX idx_metrics_complexity ON metrics(complexity)')
    cursor.execute('CREATE INDEX idx_metrics_dependent_count ON metrics(dependent_count)')
    cursor.execute('CREATE INDEX idx_findings_artifact_id ON findings(artifact_id)')
    cursor.execute('CREATE INDEX idx_issues_artifact_id ON issues(artifact_id)')
    cursor.execute('CREATE INDEX idx_recommendations_artifact_id ON recommendations(artifact_id)')
    cursor.execute('CREATE INDEX idx_dependencies_source ON dependencies(source_artifact_id)')
    cursor.execute('CREATE INDEX idx_dependencies_target ON dependencies(target_artifact_id)')
    cursor.execute('CREATE INDEX idx_audit_trail_artifact_id ON audit_trail(artifact_id)')
    cursor.execute('CREATE INDEX idx_staleness_artifact_id ON staleness(artifact_id)')
    
    # Create views for common queries
    cursor.execute('''
        CREATE VIEW high_complexity_functions AS
        SELECT a.id, a.name, a.path, m.complexity, m.dependent_count
        FROM artifacts a
        JOIN metrics m ON a.id = m.artifact_id
        WHERE a.type = 'function' AND m.complexity > 10
        ORDER BY m.complexity DESC
    ''')
    
    cursor.execute('''
        CREATE VIEW high_risk_functions AS
        SELECT a.id, a.name, a.path, m.complexity, m.dependent_count
        FROM artifacts a
        JOIN metrics m ON a.id = m.artifact_id
        WHERE a.type = 'function' AND (m.complexity > 10 OR m.dependent_count > 15)
        ORDER BY m.complexity DESC, m.dependent_count DESC
    ''')
    
    cursor.execute('''
        CREATE VIEW stale_knowledge AS
        SELECT a.id, a.name, a.type, s.status, s.days_since_update
        FROM artifacts a
        JOIN staleness s ON a.id = s.artifact_id
        WHERE s.status IN ('STALE', 'VERY_STALE')
        ORDER BY s.days_since_update DESC
    ''')
    
    cursor.execute('''
        CREATE VIEW recent_changes AS
        SELECT a.id, a.name, a.type, a.updated_at, a.updated_by
        FROM artifacts a
        ORDER BY a.updated_at DESC
        LIMIT 100
    ''')
    
    conn.commit()

def main():
    parser = argparse.ArgumentParser(description='Initialize SQLite database for AKR')
    parser.add_argument('--force', action='store_true', help='Drop existing database and recreate')
    args = parser.parse_args()
    
    db_path = get_db_path()
    db_dir = os.path.dirname(db_path)
    
    # Ensure directory exists
    Path(db_dir).mkdir(parents=True, exist_ok=True)
    
    # Handle force recreate
    if args.force and os.path.exists(db_path):
        print(f"[INFO] Removing existing database: {db_path}")
        os.remove(db_path)
    
    # Check if database already exists
    if os.path.exists(db_path):
        print(f"[INFO] Database already exists: {db_path}")
        print("[INFO] Use --force to recreate")
        return 0
    
    print(f"[INFO] Creating SQLite database: {db_path}")
    
    try:
        conn = sqlite3.connect(db_path)
        create_schema(conn)
        conn.close()
        print(f"[INFO] Database created successfully")
        return 0
    except Exception as e:
        print(f"[ERROR] Failed to create database: {e}", file=sys.stderr)
        return 1

if __name__ == '__main__':
    sys.exit(main())
