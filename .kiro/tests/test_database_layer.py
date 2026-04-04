#!/usr/bin/env python3
"""
test_database_layer.py - Test Phase 2 database layer implementation

Purpose: Verify database initialization, sync, and query functionality

Usage:
    python3 test_database_layer.py [--verbose]
"""

import sqlite3
import os
import sys
import tempfile
from pathlib import Path

# Add scripts to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'scripts'))

from init_akr_db import create_schema

class TestRunner:
    def __init__(self, verbose=False):
        self.verbose = verbose
        self.tests_run = 0
        self.tests_passed = 0
        self.tests_failed = 0
        self.test_db = None
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
        """Setup test database."""
        self.test_db = tempfile.NamedTemporaryFile(suffix='.db', delete=False).name
        self.conn = sqlite3.connect(self.test_db)
        create_schema(self.conn)
    
    def cleanup(self):
        """Cleanup test database."""
        if self.conn:
            self.conn.close()
        if self.test_db and os.path.exists(self.test_db):
            os.remove(self.test_db)
    
    def test_database_initialization(self):
        """Test database initialization."""
        self.test_start("Database initialization")
        try:
            cursor = self.conn.cursor()
            cursor.execute("SELECT COUNT(*) FROM sqlite_master WHERE type='table'")
            table_count = cursor.fetchone()[0]
            if table_count >= 8:
                self.test_pass()
            else:
                self.test_fail(f"Expected 8+ tables, got {table_count}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_schema_verification(self):
        """Test database schema."""
        self.test_start("Database schema verification")
        try:
            cursor = self.conn.cursor()
            cursor.execute("SELECT COUNT(*) FROM sqlite_master WHERE type='table'")
            table_count = cursor.fetchone()[0]
            
            if table_count >= 8:
                self.test_pass()
            else:
                self.test_fail(f"Expected 8+ tables, got {table_count}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_indexes_created(self):
        """Test indexes created."""
        self.test_start("Indexes created")
        try:
            cursor = self.conn.cursor()
            cursor.execute("SELECT COUNT(*) FROM sqlite_master WHERE type='index'")
            index_count = cursor.fetchone()[0]
            
            if index_count > 0:
                self.test_pass()
            else:
                self.test_fail("No indexes found")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_views_created(self):
        """Test views created."""
        self.test_start("Views created")
        try:
            cursor = self.conn.cursor()
            cursor.execute("SELECT COUNT(*) FROM sqlite_master WHERE type='view'")
            view_count = cursor.fetchone()[0]
            
            if view_count >= 4:
                self.test_pass()
            else:
                self.test_fail(f"Expected 4+ views, got {view_count}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_insert_artifact(self):
        """Test insert artifact."""
        self.test_start("Insert artifact")
        try:
            cursor = self.conn.cursor()
            cursor.execute(
                "INSERT INTO artifacts (name, type, path, status) VALUES (?, ?, ?, ?)",
                ('test_function', 'function', 'src/test.4gl', 'active')
            )
            self.conn.commit()
            self.test_pass()
        except Exception as e:
            self.test_fail(str(e))
    
    def test_insert_metrics(self):
        """Test insert metrics."""
        self.test_start("Insert metrics")
        try:
            cursor = self.conn.cursor()
            cursor.execute(
                "INSERT INTO metrics (artifact_id, complexity, lines_of_code, parameter_count, dependent_count) "
                "SELECT id, ?, ?, ?, ? FROM artifacts WHERE name=?",
                (5, 20, 2, 3, 'test_function')
            )
            self.conn.commit()
            self.test_pass()
        except Exception as e:
            self.test_fail(str(e))
    
    def test_query_artifact(self):
        """Test query artifact."""
        self.test_start("Query artifact")
        try:
            cursor = self.conn.cursor()
            cursor.execute("SELECT name FROM artifacts WHERE name=?", ('test_function',))
            result = cursor.fetchone()
            
            if result and result[0] == 'test_function':
                self.test_pass()
            else:
                self.test_fail("Artifact not found")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_query_metrics(self):
        """Test query metrics."""
        self.test_start("Query metrics")
        try:
            cursor = self.conn.cursor()
            cursor.execute("SELECT complexity FROM metrics WHERE artifact_id=1")
            result = cursor.fetchone()
            
            if result and result[0] == 5:
                self.test_pass()
            else:
                self.test_fail("Metrics not found or incorrect")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_high_complexity_view(self):
        """Test high complexity view."""
        self.test_start("High complexity view")
        try:
            cursor = self.conn.cursor()
            cursor.execute("SELECT * FROM high_complexity_functions")
            cursor.fetchall()
            self.test_pass()
        except Exception as e:
            self.test_fail(str(e))
    
    def test_audit_trail_insert(self):
        """Test audit trail insert."""
        self.test_start("Audit trail insert")
        try:
            cursor = self.conn.cursor()
            cursor.execute(
                "INSERT INTO audit_trail (action, artifact_id, agent_id, details) VALUES (?, ?, ?, ?)",
                ('TEST_ACTION', 1, 'test-agent', 'test details')
            )
            self.conn.commit()
            self.test_pass()
        except Exception as e:
            self.test_fail(str(e))
    
    def test_staleness_table(self):
        """Test staleness table."""
        self.test_start("Staleness table")
        try:
            cursor = self.conn.cursor()
            cursor.execute(
                "INSERT INTO staleness (artifact_id, status, days_since_update) VALUES (?, ?, ?)",
                (1, 'FRESH', 0)
            )
            self.conn.commit()
            self.test_pass()
        except Exception as e:
            self.test_fail(str(e))
    
    def test_database_size(self):
        """Test database size reasonable."""
        self.test_start("Database size reasonable")
        try:
            db_size = os.path.getsize(self.test_db)
            if db_size < 1000000:  # Less than 1MB
                self.test_pass()
            else:
                self.test_fail(f"Database size too large: {db_size} bytes")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_force_recreate(self):
        """Test force recreate database."""
        self.test_start("Force recreate database")
        try:
            # Close current connection
            self.conn.close()
            
            # Recreate database
            os.remove(self.test_db)
            self.conn = sqlite3.connect(self.test_db)
            create_schema(self.conn)
            
            # Verify empty
            cursor = self.conn.cursor()
            cursor.execute("SELECT COUNT(*) FROM artifacts")
            count = cursor.fetchone()[0]
            
            if count == 0:
                self.test_pass()
            else:
                self.test_fail("Database not cleared on force recreate")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_multiple_inserts(self):
        """Test multiple inserts."""
        self.test_start("Multiple inserts")
        try:
            cursor = self.conn.cursor()
            cursor.execute(
                "INSERT INTO artifacts (name, type, path, status) VALUES (?, ?, ?, ?)",
                ('func1', 'function', 'src/f1.4gl', 'active')
            )
            cursor.execute(
                "INSERT INTO artifacts (name, type, path, status) VALUES (?, ?, ?, ?)",
                ('func2', 'function', 'src/f2.4gl', 'active')
            )
            cursor.execute(
                "INSERT INTO artifacts (name, type, path, status) VALUES (?, ?, ?, ?)",
                ('mod1', 'module', 'src/m1.4gl', 'active')
            )
            self.conn.commit()
            
            cursor.execute("SELECT COUNT(*) FROM artifacts")
            count = cursor.fetchone()[0]
            
            if count >= 3:  # At least 3 (may have test_function from earlier)
                self.test_pass()
            else:
                self.test_fail(f"Expected 3+ artifacts, got {count}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_query_with_filter(self):
        """Test query with filter."""
        self.test_start("Query with filter")
        try:
            cursor = self.conn.cursor()
            cursor.execute("SELECT COUNT(*) FROM artifacts WHERE type=?", ('function',))
            count = cursor.fetchone()[0]
            
            if count >= 2:  # At least 2 functions
                self.test_pass()
            else:
                self.test_fail(f"Expected 2+ functions, got {count}")
        except Exception as e:
            self.test_fail(str(e))
    
    def run_all(self):
        """Run all tests."""
        print("Testing Phase 2: Database Layer")
        print("=" * 50)
        print()
        
        self.setup()
        
        try:
            self.test_database_initialization()
            self.test_schema_verification()
            self.test_indexes_created()
            self.test_views_created()
            self.test_insert_artifact()
            self.test_insert_metrics()
            self.test_query_artifact()
            self.test_query_metrics()
            self.test_high_complexity_view()
            self.test_audit_trail_insert()
            self.test_staleness_table()
            self.test_database_size()
            self.test_force_recreate()
            self.test_multiple_inserts()
            self.test_query_with_filter()
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
    parser = argparse.ArgumentParser(description='Test Phase 2 database layer')
    parser.add_argument('--verbose', action='store_true', help='Show detailed output')
    args = parser.parse_args()
    
    runner = TestRunner(verbose=args.verbose)
    return runner.run_all()

if __name__ == '__main__':
    sys.exit(main())
