#!/usr/bin/env python3
"""
test_integration.py - Integration tests for all AKR phases

Purpose: Verify all phases work together correctly

Usage:
    python3 test_integration.py [--verbose]
"""

import os
import sys
import tempfile
import json
import sqlite3
import subprocess
from pathlib import Path
from datetime import datetime, timedelta

# Add scripts to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'scripts'))

from init_akr_db import create_schema
from detect_staleness import detect_staleness, calculate_days_since_update
from refresh_stale_knowledge import find_stale_artifacts, mark_fresh

class IntegrationTestRunner:
    def __init__(self, verbose=False):
        self.verbose = verbose
        self.tests_run = 0
        self.tests_passed = 0
        self.tests_failed = 0
        self.test_dir = None
        self.db_path = None
        self.conn = None
    
    def test_start(self, name):
        self.tests_run += 1
        if self.verbose:
            print(f"[TEST {self.tests_run}] {name} ... ", end='', flush=True)
    
    def test_pass(self):
        self.tests_passed += 1
        if self.verbose:
            print("✓ PASS")
    
    def test_fail(self, reason):
        self.tests_failed += 1
        if self.verbose:
            print(f"✗ FAIL: {reason}")
    
    def setup(self):
        """Setup test environment."""
        self.test_dir = tempfile.mkdtemp()
        self.db_path = os.path.join(self.test_dir, f'test_integration_{id(self)}.db')
        
        # Set environment variables
        os.environ['GENERO_AKR_DB_PATH'] = self.db_path
        
        # Create test database
        self.create_test_db()
    
    def cleanup(self):
        """Cleanup test environment."""
        if self.conn:
            self.conn.close()
        
        if self.test_dir and os.path.exists(self.test_dir):
            import shutil
            shutil.rmtree(self.test_dir)
    
    def create_test_db(self):
        """Create test database with full schema."""
        self.conn = sqlite3.connect(self.db_path)
        create_schema(self.conn)
    
    def insert_artifact(self, name, atype, path=None, updated_at=None, complexity=5, dependent_count=2):
        """Insert test artifact with metrics."""
        cursor = self.conn.cursor()
        
        if updated_at is None:
            updated_at = datetime.utcnow().isoformat()
        
        cursor.execute('''
            INSERT INTO artifacts (name, type, path, updated_at)
            VALUES (?, ?, ?, ?)
        ''', (name, atype, path or f'src/{name}.4gl', updated_at))
        
        artifact_id = cursor.lastrowid
        
        # Insert metrics
        cursor.execute('''
            INSERT INTO metrics (artifact_id, complexity, lines_of_code, parameter_count, dependent_count)
            VALUES (?, ?, ?, ?, ?)
        ''', (artifact_id, complexity, 50, 1, dependent_count))
        
        # Insert staleness
        cursor.execute('''
            INSERT INTO staleness (artifact_id, status, days_since_update)
            VALUES (?, 'FRESH', 0)
        ''', (artifact_id,))
        
        self.conn.commit()
        return artifact_id
    
    def insert_audit_entry(self, action, artifact_id=None, details=None):
        """Insert audit trail entry."""
        cursor = self.conn.cursor()
        cursor.execute('''
            INSERT INTO audit_trail (action, artifact_id, agent_id, details)
            VALUES (?, ?, ?, ?)
        ''', (action, artifact_id, 'test_agent', details))
        
        self.conn.commit()
    
    def test_database_schema(self):
        """Test database schema is complete."""
        self.test_start("Database schema complete")
        try:
            cursor = self.conn.cursor()
            
            # Check all tables exist
            cursor.execute('''
                SELECT name FROM sqlite_master 
                WHERE type='table' 
                ORDER BY name
            ''')
            
            tables = [row[0] for row in cursor.fetchall()]
            required_tables = ['artifacts', 'metrics', 'findings', 'issues', 'recommendations', 
                             'dependencies', 'audit_trail', 'staleness']
            
            if all(t in tables for t in required_tables):
                self.test_pass()
            else:
                self.test_fail(f"Missing tables: {set(required_tables) - set(tables)}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_artifact_creation(self):
        """Test creating artifacts."""
        self.test_start("Create artifacts")
        try:
            aid1 = self.insert_artifact('func1', 'function')
            aid2 = self.insert_artifact('mod1', 'module')
            
            cursor = self.conn.cursor()
            cursor.execute('SELECT COUNT(*) FROM artifacts')
            count = cursor.fetchone()[0]
            
            if count == 2:
                self.test_pass()
            else:
                self.test_fail(f"Expected 2 artifacts, got {count}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_metrics_tracking(self):
        """Test metrics are tracked correctly."""
        self.test_start("Metrics tracking")
        try:
            aid = self.insert_artifact('complex_func', 'function', complexity=15, dependent_count=20)
            
            cursor = self.conn.cursor()
            cursor.execute('''
                SELECT complexity, dependent_count FROM metrics WHERE artifact_id = ?
            ''', (aid,))
            
            row = cursor.fetchone()
            if row and row[0] == 15 and row[1] == 20:
                self.test_pass()
            else:
                self.test_fail(f"Metrics not stored correctly: {row}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_audit_trail(self):
        """Test audit trail logging."""
        self.test_start("Audit trail logging")
        try:
            aid = self.insert_artifact('audit_func1', 'function')
            self.insert_audit_entry('create_artifact', aid, 'Created test artifact')
            self.insert_audit_entry('query_genero_tools', aid, 'Queried metrics')
            
            cursor = self.conn.cursor()
            cursor.execute('SELECT COUNT(*) FROM audit_trail')
            count = cursor.fetchone()[0]
            
            if count == 2:
                self.test_pass()
            else:
                self.test_fail(f"Expected 2 audit entries, got {count}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_staleness_detection(self):
        """Test staleness detection integration."""
        self.test_start("Staleness detection")
        try:
            # Create fresh artifact
            old_time = datetime.utcnow() - timedelta(days=35)
            aid = self.insert_artifact('stale_func', 'function', updated_at=old_time.isoformat())
            
            # Detect staleness
            cursor = self.conn.cursor()
            cursor.execute('''
                SELECT updated_at FROM artifacts WHERE id = ?
            ''', (aid,))
            
            updated_at = cursor.fetchone()[0]
            days = calculate_days_since_update(updated_at)
            
            if days >= 34 and days <= 36:
                self.test_pass()
            else:
                self.test_fail(f"Expected ~35 days, got {days}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_staleness_refresh(self):
        """Test staleness refresh integration."""
        self.test_start("Staleness refresh")
        try:
            # Create stale artifact
            old_time = datetime.utcnow() - timedelta(days=35)
            aid = self.insert_artifact('refresh_func1', 'function', updated_at=old_time.isoformat())
            
            # Mark as stale
            cursor = self.conn.cursor()
            cursor.execute('''
                UPDATE staleness SET status = 'STALE', days_since_update = 35 WHERE artifact_id = ?
            ''', (aid,))
            self.conn.commit()
            
            # Mark as fresh
            if mark_fresh(self.conn, aid):
                # Verify
                cursor.execute('SELECT status FROM staleness WHERE artifact_id = ?', (aid,))
                status = cursor.fetchone()[0]
                
                if status == 'FRESH':
                    self.test_pass()
                else:
                    self.test_fail(f"Status not updated to FRESH: {status}")
            else:
                self.test_fail("mark_fresh returned False")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_concurrent_artifacts(self):
        """Test handling multiple artifacts."""
        self.test_start("Concurrent artifacts")
        try:
            # Create multiple artifacts
            for i in range(10):
                self.insert_artifact(f'concurrent_func_{i}', 'function', complexity=i+1, dependent_count=i)
            
            cursor = self.conn.cursor()
            cursor.execute('SELECT COUNT(*) FROM artifacts')
            count = cursor.fetchone()[0]
            
            # Just verify we have at least 10 artifacts
            if count >= 10:
                self.test_pass()
            else:
                self.test_fail(f"Expected at least 10 artifacts, got {count}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_high_complexity_detection(self):
        """Test detecting high-complexity functions."""
        self.test_start("High-complexity detection")
        try:
            # Create high-complexity artifact
            aid = self.insert_artifact('complex_func1', 'function', complexity=15, dependent_count=20)
            
            # Query high-complexity view
            cursor = self.conn.cursor()
            cursor.execute('''
                SELECT COUNT(*) FROM high_complexity_functions WHERE complexity > 10
            ''')
            
            count = cursor.fetchone()[0]
            if count >= 1:
                self.test_pass()
            else:
                self.test_fail(f"Expected high-complexity function, got {count}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_dependency_tracking(self):
        """Test dependency tracking."""
        self.test_start("Dependency tracking")
        try:
            aid1 = self.insert_artifact('dep_func1', 'function')
            aid2 = self.insert_artifact('dep_func2', 'function')
            
            # Create dependency
            cursor = self.conn.cursor()
            cursor.execute('''
                INSERT INTO dependencies (source_artifact_id, target_artifact_id, dependency_type)
                VALUES (?, ?, 'calls')
            ''', (aid1, aid2))
            self.conn.commit()
            
            # Verify dependency
            cursor.execute('''
                SELECT COUNT(*) FROM dependencies WHERE source_artifact_id = ? AND target_artifact_id = ?
            ''', (aid1, aid2))
            
            count = cursor.fetchone()[0]
            if count == 1:
                self.test_pass()
            else:
                self.test_fail(f"Dependency not created")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_findings_and_issues(self):
        """Test findings and issues tracking."""
        self.test_start("Findings and issues")
        try:
            aid = self.insert_artifact('findings_func1', 'function')
            
            cursor = self.conn.cursor()
            
            # Add finding
            cursor.execute('''
                INSERT INTO findings (artifact_id, finding, priority)
                VALUES (?, ?, 'HIGH')
            ''', (aid, 'High complexity detected'))
            
            # Add issue
            cursor.execute('''
                INSERT INTO issues (artifact_id, issue_type, severity, description)
                VALUES (?, ?, ?, ?)
            ''', (aid, 'complexity', 'HIGH', 'Complexity exceeds threshold'))
            
            self.conn.commit()
            
            # Verify
            cursor.execute('SELECT COUNT(*) FROM findings WHERE artifact_id = ?', (aid,))
            findings_count = cursor.fetchone()[0]
            
            cursor.execute('SELECT COUNT(*) FROM issues WHERE artifact_id = ?', (aid,))
            issues_count = cursor.fetchone()[0]
            
            if findings_count == 1 and issues_count == 1:
                self.test_pass()
            else:
                self.test_fail(f"Findings: {findings_count}, Issues: {issues_count}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_recommendations(self):
        """Test recommendations tracking."""
        self.test_start("Recommendations")
        try:
            aid = self.insert_artifact('rec_func1', 'function')
            
            cursor = self.conn.cursor()
            cursor.execute('''
                INSERT INTO recommendations (artifact_id, recommendation, priority)
                VALUES (?, ?, 'HIGH')
            ''', (aid, 'Break into smaller functions'))
            
            self.conn.commit()
            
            cursor.execute('SELECT COUNT(*) FROM recommendations WHERE artifact_id = ?', (aid,))
            count = cursor.fetchone()[0]
            
            if count == 1:
                self.test_pass()
            else:
                self.test_fail(f"Expected 1 recommendation, got {count}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_artifact_status_tracking(self):
        """Test artifact status tracking."""
        self.test_start("Artifact status tracking")
        try:
            aid = self.insert_artifact('status_func1', 'function')
            
            cursor = self.conn.cursor()
            
            # Verify initial status
            cursor.execute('SELECT status FROM artifacts WHERE id = ?', (aid,))
            status = cursor.fetchone()[0]
            
            if status == 'active':
                # Update status
                cursor.execute('UPDATE artifacts SET status = ? WHERE id = ?', ('deprecated', aid))
                self.conn.commit()
                
                # Verify update
                cursor.execute('SELECT status FROM artifacts WHERE id = ?', (aid,))
                new_status = cursor.fetchone()[0]
                
                if new_status == 'deprecated':
                    self.test_pass()
                else:
                    self.test_fail(f"Status not updated: {new_status}")
            else:
                self.test_fail(f"Initial status not 'active': {status}")
        except Exception as e:
            self.test_fail(str(e))
    
    def run_all(self):
        """Run all tests."""
        print("Integration Testing: All Phases")
        print("=" * 50)
        print()
        
        self.setup()
        
        try:
            self.test_database_schema()
            self.test_artifact_creation()
            self.test_metrics_tracking()
            self.test_audit_trail()
            self.test_staleness_detection()
            self.test_staleness_refresh()
            self.test_concurrent_artifacts()
            self.test_high_complexity_detection()
            self.test_dependency_tracking()
            self.test_findings_and_issues()
            self.test_recommendations()
            self.test_artifact_status_tracking()
        finally:
            self.cleanup()
        
        # Print summary
        print()
        print("=" * 50)
        print("Integration Test Results")
        print("=" * 50)
        print(f"Tests run:    {self.tests_run}")
        print(f"Tests passed: {self.tests_passed}")
        print(f"Tests failed: {self.tests_failed}")
        print()
        
        if self.tests_failed == 0:
            print("✓ All integration tests passed!")
            return 0
        else:
            print(f"✗ {self.tests_failed} test(s) failed")
            return 1

def main():
    import argparse
    parser = argparse.ArgumentParser(description='Integration tests for all AKR phases')
    parser.add_argument('--verbose', action='store_true', help='Show detailed output')
    args = parser.parse_args()
    
    runner = IntegrationTestRunner(verbose=args.verbose)
    return runner.run_all()

if __name__ == '__main__':
    sys.exit(main())
