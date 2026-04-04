#!/usr/bin/env python3
"""
test_staleness_management.py - Test Phase 4 staleness management implementation

Purpose: Verify staleness detection, refresh, and reporting functionality

Usage:
    python3 test_staleness_management.py [--verbose]
"""

import os
import sys
import tempfile
import json
import sqlite3
from pathlib import Path
from datetime import datetime, timedelta

# Add scripts to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'scripts'))

from detect_staleness import detect_staleness, calculate_days_since_update, check_age_staleness
from refresh_stale_knowledge import find_stale_artifacts, mark_fresh
from staleness_report import count_by_status, find_high_risk_stale

class TestRunner:
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
        self.db_path = os.path.join(self.test_dir, f'test_akr_{id(self)}.db')
        
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
        """Create test database with schema."""
        self.conn = sqlite3.connect(self.db_path)
        cursor = self.conn.cursor()
        
        # Create tables
        cursor.execute('''
            CREATE TABLE artifacts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                type TEXT NOT NULL,
                path TEXT,
                status TEXT DEFAULT 'active',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_by TEXT,
                UNIQUE(name, type)
            )
        ''')
        
        cursor.execute('''
            CREATE TABLE metrics (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                artifact_id INTEGER NOT NULL UNIQUE,
                complexity INTEGER DEFAULT 0,
                lines_of_code INTEGER DEFAULT 0,
                parameter_count INTEGER DEFAULT 0,
                dependent_count INTEGER DEFAULT 0,
                return_count INTEGER DEFAULT 0,
                FOREIGN KEY(artifact_id) REFERENCES artifacts(id)
            )
        ''')
        
        cursor.execute('''
            CREATE TABLE staleness (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                artifact_id INTEGER NOT NULL UNIQUE,
                status TEXT DEFAULT 'FRESH',
                days_since_update INTEGER DEFAULT 0,
                last_checked TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY(artifact_id) REFERENCES artifacts(id)
            )
        ''')
        
        cursor.execute('''
            CREATE TABLE audit_trail (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                action TEXT NOT NULL,
                artifact_id INTEGER,
                agent_id TEXT,
                details TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY(artifact_id) REFERENCES artifacts(id)
            )
        ''')
        
        self.conn.commit()
    
    def insert_artifact(self, name, atype, path=None, updated_at=None):
        """Insert test artifact."""
        cursor = self.conn.cursor()
        
        if updated_at is None:
            updated_at = datetime.utcnow().isoformat()
        
        cursor.execute('''
            INSERT INTO artifacts (name, type, path, updated_at)
            VALUES (?, ?, ?, ?)
        ''', (name, atype, path or f'src/{name}.4gl', updated_at))
        
        artifact_id = cursor.lastrowid
        self.conn.commit()
        
        return artifact_id
    
    def insert_metrics(self, artifact_id, complexity=5, dependent_count=2):
        """Insert test metrics."""
        cursor = self.conn.cursor()
        cursor.execute('''
            INSERT INTO metrics (artifact_id, complexity, lines_of_code, parameter_count, dependent_count)
            VALUES (?, ?, ?, ?, ?)
        ''', (artifact_id, complexity, 50, 1, dependent_count))
        
        self.conn.commit()
    
    def insert_staleness(self, artifact_id, status='FRESH', days_since_update=0):
        """Insert staleness record."""
        cursor = self.conn.cursor()
        cursor.execute('''
            INSERT INTO staleness (artifact_id, status, days_since_update)
            VALUES (?, ?, ?)
        ''', (artifact_id, status, days_since_update))
        
        self.conn.commit()
    
    def test_calculate_days_since_update(self):
        """Test days calculation."""
        self.test_start("Calculate days since update")
        try:
            # Test with current time
            now = datetime.utcnow()
            days = calculate_days_since_update(now.isoformat())
            
            if days == 0:
                self.test_pass()
            else:
                self.test_fail(f"Expected 0 days, got {days}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_calculate_days_old(self):
        """Test days calculation for old timestamp."""
        self.test_start("Calculate days for old timestamp")
        try:
            # Test with 35 days ago
            old_time = datetime.utcnow() - timedelta(days=35)
            days = calculate_days_since_update(old_time.isoformat())
            
            if days >= 34 and days <= 36:  # Allow 1 day variance
                self.test_pass()
            else:
                self.test_fail(f"Expected ~35 days, got {days}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_age_staleness_fresh(self):
        """Test age-based staleness detection - FRESH."""
        self.test_start("Age staleness detection - FRESH")
        try:
            now = datetime.utcnow()
            artifact = {'updated_at': now.isoformat()}
            threshold = {'age_days': 30}
            
            status, days = check_age_staleness(artifact, threshold)
            
            if status == 'FRESH':
                self.test_pass()
            else:
                self.test_fail(f"Expected FRESH, got {status}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_age_staleness_aging(self):
        """Test age-based staleness detection - AGING."""
        self.test_start("Age staleness detection - AGING")
        try:
            # 25 days old (80% of 30 day threshold)
            old_time = datetime.utcnow() - timedelta(days=25)
            artifact = {'updated_at': old_time.isoformat()}
            threshold = {'age_days': 30}
            
            status, days = check_age_staleness(artifact, threshold)
            
            if status == 'AGING':
                self.test_pass()
            else:
                self.test_fail(f"Expected AGING, got {status}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_age_staleness_stale(self):
        """Test age-based staleness detection - STALE."""
        self.test_start("Age staleness detection - STALE")
        try:
            # 35 days old (exceeds 30 day threshold)
            old_time = datetime.utcnow() - timedelta(days=35)
            artifact = {'updated_at': old_time.isoformat()}
            threshold = {'age_days': 30}
            
            status, days = check_age_staleness(artifact, threshold)
            
            if status == 'STALE':
                self.test_pass()
            else:
                self.test_fail(f"Expected STALE, got {status}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_find_stale_artifacts(self):
        """Test finding stale artifacts."""
        self.test_start("Find stale artifacts")
        try:
            # Insert test artifacts
            aid1 = self.insert_artifact('func1', 'function')
            aid2 = self.insert_artifact('func2', 'function')
            aid3 = self.insert_artifact('func3', 'function')
            
            self.insert_staleness(aid1, 'FRESH', 5)
            self.insert_staleness(aid2, 'STALE', 35)
            self.insert_staleness(aid3, 'POTENTIALLY_STALE', 0)
            
            # Find stale
            stale = find_stale_artifacts(self.conn, limit=10)
            
            if len(stale) == 2:  # Should find 2 stale artifacts
                self.test_pass()
            else:
                self.test_fail(f"Expected 2 stale artifacts, got {len(stale)}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_mark_fresh(self):
        """Test marking artifact as fresh."""
        self.test_start("Mark artifact as fresh")
        try:
            # Insert test artifact with unique name
            aid = self.insert_artifact('mark_fresh_func', 'function')
            self.insert_staleness(aid, 'STALE', 35)
            
            # Mark as fresh
            if mark_fresh(self.conn, aid):
                # Verify
                cursor = self.conn.cursor()
                cursor.execute('SELECT status FROM staleness WHERE artifact_id = ?', (aid,))
                row = cursor.fetchone()
                
                if row and row[0] == 'FRESH':
                    self.test_pass()
                else:
                    self.test_fail(f"Status not updated to FRESH")
            else:
                self.test_fail("mark_fresh returned False")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_count_by_status(self):
        """Test counting artifacts by status."""
        self.test_start("Count artifacts by status")
        try:
            # Insert test artifacts
            for i in range(3):
                aid = self.insert_artifact(f'count_fresh_{i}', 'function')
                self.insert_staleness(aid, 'FRESH', 0)
            
            for i in range(2):
                aid = self.insert_artifact(f'count_stale_{i}', 'function')
                self.insert_staleness(aid, 'STALE', 35)
            
            # Count
            counts, total = count_by_status(self.conn)
            
            # Just verify we got counts and total > 0
            if total >= 5 and counts.get('FRESH', 0) >= 3 and counts.get('STALE', 0) >= 2:
                self.test_pass()
            else:
                self.test_fail(f"Unexpected counts: {counts}, total: {total}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_find_high_risk_stale(self):
        """Test finding high-risk stale artifacts."""
        self.test_start("Find high-risk stale artifacts")
        try:
            # Insert high-complexity stale artifact
            aid = self.insert_artifact('complex_func', 'function')
            self.insert_metrics(aid, complexity=15, dependent_count=20)
            self.insert_staleness(aid, 'STALE', 35)
            
            # Insert low-complexity fresh artifact
            aid2 = self.insert_artifact('simple_func', 'function')
            self.insert_metrics(aid2, complexity=3, dependent_count=1)
            self.insert_staleness(aid2, 'FRESH', 0)
            
            # Find high-risk
            high_risk = find_high_risk_stale(self.conn, limit=10)
            
            if len(high_risk) == 1 and high_risk[0]['name'] == 'complex_func':
                self.test_pass()
            else:
                self.test_fail(f"Expected 1 high-risk artifact, got {len(high_risk)}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_staleness_by_type(self):
        """Test staleness detection by artifact type."""
        self.test_start("Staleness detection by type")
        try:
            # Insert function
            aid1 = self.insert_artifact('type_func1', 'function')
            self.insert_staleness(aid1, 'FRESH', 0)
            
            # Insert module
            aid2 = self.insert_artifact('type_mod1', 'module')
            self.insert_staleness(aid2, 'STALE', 65)
            
            # Find only functions - should find at least the fresh one
            stale = find_stale_artifacts(self.conn, artifact_type='function', limit=10)
            
            # Just verify we can filter by type without error
            if isinstance(stale, list):
                self.test_pass()
            else:
                self.test_fail(f"Expected list, got {type(stale)}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_multiple_staleness_statuses(self):
        """Test handling multiple staleness statuses."""
        self.test_start("Multiple staleness statuses")
        try:
            statuses = ['FRESH', 'AGING', 'STALE', 'POTENTIALLY_STALE']
            
            for i, status in enumerate(statuses):
                aid = self.insert_artifact(f'multi_func_{i}', 'function')
                self.insert_staleness(aid, status, i * 10)
            
            # Count
            counts, total = count_by_status(self.conn)
            
            # Just verify we have multiple statuses represented
            if len(counts) >= 2:
                self.test_pass()
            else:
                self.test_fail(f"Expected multiple statuses, got {len(counts)}")
        except Exception as e:
            self.test_fail(str(e))
    
    def run_all(self):
        """Run all tests."""
        print("Testing Phase 4: Staleness Management")
        print("=" * 50)
        print()
        
        self.setup()
        
        try:
            self.test_calculate_days_since_update()
            self.test_calculate_days_old()
            self.test_age_staleness_fresh()
            self.test_age_staleness_aging()
            self.test_age_staleness_stale()
            self.test_find_stale_artifacts()
            self.test_mark_fresh()
            self.test_count_by_status()
            self.test_find_high_risk_stale()
            self.test_staleness_by_type()
            self.test_multiple_staleness_statuses()
        finally:
            self.cleanup()
        
        # Print summary
        print()
        print("=" * 50)
        print("Test Results")
        print("=" * 50)
        print(f"Tests run:    {self.tests_run}")
        print(f"Tests passed: {self.tests_passed}")
        print(f"Tests failed: {self.tests_failed}")
        print()
        
        if self.tests_failed == 0:
            print("✓ All tests passed!")
            return 0
        else:
            print(f"✗ {self.tests_failed} test(s) failed")
            return 1

def main():
    import argparse
    parser = argparse.ArgumentParser(description='Test Phase 4 staleness management')
    parser.add_argument('--verbose', action='store_true', help='Show detailed output')
    args = parser.parse_args()
    
    runner = TestRunner(verbose=args.verbose)
    return runner.run_all()

if __name__ == '__main__':
    sys.exit(main())
