#!/usr/bin/env python3
"""
refresh_stale_knowledge.py - Automatically refresh stale knowledge

Purpose: Find stale artifacts, re-query genero-tools, update AKR with new findings

Usage:
    python3 refresh_stale_knowledge.py [--limit N] [--type TYPE] [--dry-run]

Options:
    --limit N     Refresh maximum N artifacts (default: 10)
    --type TYPE   Refresh only specific type (function, module, file, pattern, issue)
    --dry-run     Show what would be refreshed without making changes
"""

import json
import os
import sys
import argparse
import sqlite3
import subprocess
from pathlib import Path
from datetime import datetime

def get_db_path():
    """Get database path from environment or use default."""
    db_path = os.environ.get('GENERO_AKR_DB_PATH')
    if db_path:
        return db_path
    
    brodir = os.environ.get('BRODIR', '/opt/genero')
    return os.path.join(brodir, 'etc', 'genero-akr', 'akr.db')

def get_akr_base_path():
    """Get AKR base path from environment or use default."""
    akr_path = os.environ.get('GENERO_AKR_BASE_PATH')
    if akr_path:
        return akr_path
    
    brodir = os.environ.get('BRODIR', '/opt/genero')
    return os.path.join(brodir, 'etc', 'genero-akr')

def find_stale_artifacts(conn, artifact_type=None, limit=10):
    """Find stale artifacts in database."""
    try:
        cursor = conn.cursor()
        
        query = '''
            SELECT a.id, a.name, a.type, a.path, s.status, s.days_since_update
            FROM artifacts a
            JOIN staleness s ON a.id = s.artifact_id
            WHERE s.status IN ('STALE', 'POTENTIALLY_STALE')
            AND a.status = 'active'
        '''
        params = []
        
        if artifact_type:
            query += ' AND a.type = ?'
            params.append(artifact_type)
        
        query += ' ORDER BY s.days_since_update DESC LIMIT ?'
        params.append(limit)
        
        cursor.execute(query, params)
        return cursor.fetchall()
    except Exception as e:
        print(f"[WARNING] Failed to find stale artifacts: {e}", file=sys.stderr)
        return []

def get_artifact_metrics(conn, artifact_id):
    """Get current metrics for an artifact."""
    try:
        cursor = conn.cursor()
        cursor.execute('''
            SELECT complexity, lines_of_code, parameter_count, dependent_count, return_count
            FROM metrics
            WHERE artifact_id = ?
        ''', (artifact_id,))
        
        row = cursor.fetchone()
        if row:
            return {
                'complexity': row[0],
                'lines_of_code': row[1],
                'parameter_count': row[2],
                'dependent_count': row[3],
                'return_count': row[4]
            }
        return None
    except Exception as e:
        return None

def query_genero_tools(artifact_name, artifact_type):
    """Query genero-tools for updated metrics."""
    try:
        if artifact_type != 'function':
            # For now, only support function queries
            return None
        
        # Try to query genero-tools
        brodir = os.environ.get('BRODIR', '/opt/genero')
        query_script = os.path.join(brodir, 'etc', 'genero-tools', 'query.sh')
        
        if not os.path.exists(query_script):
            return None
        
        result = subprocess.run(
            ['bash', query_script, 'find-function', artifact_name],
            capture_output=True,
            text=True,
            timeout=10
        )
        
        if result.returncode == 0:
            return json.loads(result.stdout)
        return None
    except Exception as e:
        print(f"[WARNING] Failed to query genero-tools: {e}", file=sys.stderr)
        return None

def update_artifact_metrics(conn, artifact_id, metrics):
    """Update artifact metrics in database."""
    try:
        cursor = conn.cursor()
        cursor.execute('''
            INSERT OR REPLACE INTO metrics
            (artifact_id, complexity, lines_of_code, parameter_count, dependent_count, return_count)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (
            artifact_id,
            metrics.get('complexity', 0),
            metrics.get('lines_of_code', 0),
            metrics.get('parameter_count', 0),
            metrics.get('dependent_count', 0),
            metrics.get('return_count', 0)
        ))
        
        conn.commit()
        return True
    except Exception as e:
        print(f"[WARNING] Failed to update metrics: {e}", file=sys.stderr)
        return False

def mark_fresh(conn, artifact_id):
    """Mark artifact as FRESH after refresh."""
    try:
        cursor = conn.cursor()
        cursor.execute('''
            UPDATE staleness
            SET status = 'FRESH', days_since_update = 0, last_checked = CURRENT_TIMESTAMP
            WHERE artifact_id = ?
        ''', (artifact_id,))
        
        cursor.execute('''
            UPDATE artifacts
            SET updated_at = CURRENT_TIMESTAMP
            WHERE id = ?
        ''', (artifact_id,))
        
        conn.commit()
        return True
    except Exception as e:
        print(f"[WARNING] Failed to mark fresh: {e}", file=sys.stderr)
        return False

def log_refresh_action(conn, artifact_id, action, details):
    """Log refresh action to audit trail."""
    try:
        cursor = conn.cursor()
        cursor.execute('''
            INSERT INTO audit_trail (action, artifact_id, agent_id, details)
            VALUES (?, ?, ?, ?)
        ''', ('refresh_stale_knowledge', artifact_id, 'system', details))
        
        conn.commit()
        return True
    except Exception as e:
        return False

def refresh_stale_knowledge(limit=10, artifact_type=None, dry_run=False):
    """Refresh stale knowledge."""
    db_path = get_db_path()
    
    if not os.path.exists(db_path):
        print("[INFO] Database not found")
        return 0
    
    try:
        conn = sqlite3.connect(db_path)
        
        # Find stale artifacts
        stale_artifacts = find_stale_artifacts(conn, artifact_type, limit)
        
        if not stale_artifacts:
            print("[INFO] No stale artifacts found")
            conn.close()
            return 0
        
        print(f"[INFO] Found {len(stale_artifacts)} stale artifact(s)")
        
        refreshed_count = 0
        
        for artifact in stale_artifacts:
            artifact_id, name, atype, path, status, days_since_update = artifact
            
            print(f"[INFO] Processing: {name} ({atype}) - {status}, {days_since_update} days old")
            
            if dry_run:
                print(f"  [DRY-RUN] Would refresh {name}")
                refreshed_count += 1
                continue
            
            # Query genero-tools for updated metrics
            new_metrics = query_genero_tools(name, atype)
            
            if new_metrics:
                # Get old metrics for comparison
                old_metrics = get_artifact_metrics(conn, artifact_id)
                
                # Update metrics in database
                if update_artifact_metrics(conn, artifact_id, new_metrics):
                    # Mark as FRESH
                    if mark_fresh(conn, artifact_id):
                        # Log action
                        details = json.dumps({
                            'old_metrics': old_metrics,
                            'new_metrics': new_metrics,
                            'previous_status': status,
                            'days_since_update': days_since_update
                        })
                        log_refresh_action(conn, artifact_id, 'refresh', details)
                        
                        print(f"  ✓ Refreshed {name}")
                        refreshed_count += 1
                    else:
                        print(f"  ✗ Failed to mark {name} as fresh")
                else:
                    print(f"  ✗ Failed to update metrics for {name}")
            else:
                print(f"  ✗ Could not query genero-tools for {name}")
        
        conn.close()
        
        print(f"[INFO] Refreshed {refreshed_count}/{len(stale_artifacts)} artifact(s)")
        return refreshed_count
    
    except Exception as e:
        print(f"[ERROR] Failed to refresh stale knowledge: {e}", file=sys.stderr)
        return 0

def main():
    parser = argparse.ArgumentParser(description='Refresh stale knowledge')
    parser.add_argument('--limit', type=int, default=10, help='Maximum artifacts to refresh')
    parser.add_argument('--type', dest='artifact_type', help='Refresh only specific type')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be refreshed')
    args = parser.parse_args()
    
    refreshed = refresh_stale_knowledge(
        limit=args.limit,
        artifact_type=args.artifact_type,
        dry_run=args.dry_run
    )
    
    return 0 if refreshed > 0 else 1

if __name__ == '__main__':
    sys.exit(main())
