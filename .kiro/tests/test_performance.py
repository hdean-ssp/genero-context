#!/usr/bin/env python3
"""
test_performance.py - Performance tests for AKR framework

Purpose: Verify performance targets are met

Usage:
    python3 test_performance.py [--verbose]
"""

import os
import sys
import tempfile
import time
import sqlite3
from pathlib import Path
from datetime import datetime

# Add scripts to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'scripts'))

from init_akr_db import create_schema

class PerformanceTestRunner:
    def __init__(self, verbose=False):
        self.verbose = verbose
        self.tests_run = 0
        self.tests_passed = 0
        self.tests_failed = 0
        self.test_dir = None
        self.db_path = None
        self.conn = None
    
    def test_start(self, name, target_ms):
        self.tests_run += 1
        if self.verbose:
            print(f"[TEST {self.tests_run}] {name} (target: <{target_ms}ms) ... ", end='', flush=True)
    
    def test_pass(self, elapsed_ms):
        self.tests_passed += 1
        if self.verbose:
            print(f"✓ PASS ({elapsed_ms:.1f}ms)")
    
    def test_fail(self, reason):
        self.tests_failed += 1
        if self.verbose:
            print(f"✗ FAIL: {reason}")
    
    def setup(self):
        """Setup test environment."""
        self.test_dir = tempfile.mkdtemp()
        self.db_path = os.path.join(self.test_dir, f'test_perf_{id(self)}.db')
        
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
    
    def populate_artifacts(self, count, prefix='perf'):
        """Populate database with N artifacts."""
        cursor = self.conn.cursor()
        
        for i in range(count):
            cursor.execute('''
                INSERT INTO artifacts (name, type, path, updated_at)
                VALUES (?, ?, ?, ?)
            ''', (f'{prefix}_func_{i}_{id(self)}', 'function', f'src/{prefix}_func_{i}.4gl', datetime.utcnow().isoformat()))
            
            artifact_id = cursor.lastrowid
            
            # Insert metrics
            cursor.execute('''
                INSERT INTO metrics (artifact_id, complexity, lines_of_code, parameter_count, dependent_count)
                VALUES (?, ?, ?, ?, ?)
            ''', (artifact_id, (i % 20) + 1, 50 + i, 1, i % 10))
            
            # Insert staleness
            cursor.execute('''
                INSERT INTO staleness (artifact_id, status, days_since_update)
                VALUES (?, 'FRESH', ?)
            ''', (artifact_id, i % 30))
        
        self.conn.commit()
    
    def test_query_performance_100(self):
        """Test query performance with 100 artifacts."""
        self.test_start("Query 100 artifacts", 100)
        try:
            self.populate_artifacts(100, 'q100')
            
            cursor = self.conn.cursor()
            
            start = time.time()
            cursor.execute('SELECT * FROM artifacts WHERE type = ?', ('function',))
            results = cursor.fetchall()
            elapsed = (time.time() - start) * 1000
            
            if elapsed < 100 and len(results) >= 100:
                self.test_pass(elapsed)
            else:
                self.test_fail(f"Query took {elapsed:.1f}ms, got {len(results)} results")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_query_performance_1000(self):
        """Test query performance with 1000 artifacts."""
        self.test_start("Query 1000 artifacts", 100)
        try:
            self.populate_artifacts(1000, 'q1000')
            
            cursor = self.conn.cursor()
            
            start = time.time()
            cursor.execute('''
                SELECT a.id FROM artifacts a
                JOIN metrics m ON a.id = m.artifact_id
                WHERE m.complexity > ?
            ''', (10,))
            results = cursor.fetchall()
            elapsed = (time.time() - start) * 1000
            
            if elapsed < 100:
                self.test_pass(elapsed)
            else:
                self.test_fail(f"Query took {elapsed:.1f}ms")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_staleness_detection_performance(self):
        """Test staleness detection performance."""
        self.test_start("Staleness detection (100 artifacts)", 100)
        try:
            self.populate_artifacts(100, 'stale')
            
            start = time.time()
            cursor = self.conn.cursor()
            cursor.execute('''
                SELECT COUNT(*) FROM staleness WHERE status IN ('STALE', 'POTENTIALLY_STALE')
            ''')
            count = cursor.fetchone()[0]
            elapsed = (time.time() - start) * 1000
            
            if elapsed < 100:
                self.test_pass(elapsed)
            else:
                self.test_fail(f"Detection took {elapsed:.1f}ms")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_insert_performance(self):
        """Test insert performance."""
        self.test_start("Insert 100 artifacts", 500)
        try:
            cursor = self.conn.cursor()
            
            start = time.time()
            for i in range(100):
                cursor.execute('''
                    INSERT INTO artifacts (name, type, path, updated_at)
                    VALUES (?, ?, ?, ?)
                ''', (f'insert_func_{i}', 'function', f'src/insert_{i}.4gl', datetime.utcnow().isoformat()))
                
                artifact_id = cursor.lastrowid
                cursor.execute('''
                    INSERT INTO metrics (artifact_id, complexity, lines_of_code, parameter_count, dependent_count)
                    VALUES (?, ?, ?, ?, ?)
                ''', (artifact_id, 5, 50, 1, 2))
                
                cursor.execute('''
                    INSERT INTO staleness (artifact_id, status, days_since_update)
                    VALUES (?, 'FRESH', 0)
                ''', (artifact_id,))
            
            self.conn.commit()
            elapsed = (time.time() - start) * 1000
            
            if elapsed < 500:
                self.test_pass(elapsed)
            else:
                self.test_fail(f"Insert took {elapsed:.1f}ms")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_audit_trail_performance(self):
        """Test audit trail insert performance."""
        self.test_start("Audit trail (100 entries)", 100)
        try:
            cursor = self.conn.cursor()
            
            start = time.time()
            for i in range(100):
                cursor.execute('''
                    INSERT INTO audit_trail (action, agent_id, details)
                    VALUES (?, ?, ?)
                ''', (f'action_{i}', 'test_agent', f'Details for action {i}'))
            
            self.conn.commit()
            elapsed = (time.time() - start) * 1000
            
            if elapsed < 100:
                self.test_pass(elapsed)
            else:
                self.test_fail(f"Audit trail took {elapsed:.1f}ms")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_complex_query_performance(self):
        """Test complex query performance."""
        self.test_start("Complex query (high-risk functions)", 100)
        try:
            self.populate_artifacts(500, 'complex')
            
            cursor = self.conn.cursor()
            
            start = time.time()
            cursor.execute('''
                SELECT a.id, a.name, m.complexity, m.dependent_count
                FROM artifacts a
                JOIN metrics m ON a.id = m.artifact_id
                WHERE m.complexity > 10 OR m.dependent_count > 5
                ORDER BY m.complexity DESC
            ''')
            results = cursor.fetchall()
            elapsed = (time.time() - start) * 1000
            
            if elapsed < 100:
                self.test_pass(elapsed)
            else:
                self.test_fail(f"Complex query took {elapsed:.1f}ms")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_index_performance(self):
        """Test that indexes are working."""
        self.test_start("Index performance (complexity filter)", 50)
        try:
            self.populate_artifacts(1000, 'index')
            
            cursor = self.conn.cursor()
            
            start = time.time()
            cursor.execute('''
                SELECT COUNT(*) FROM metrics WHERE complexity > 15
            ''')
            count = cursor.fetchone()[0]
            elapsed = (time.time() - start) * 1000
            
            if elapsed < 50:
                self.test_pass(elapsed)
            else:
                self.test_fail(f"Index query took {elapsed:.1f}ms")
        except Exception as e:
            self.test_fail(str(e))
    
    def run_all(self):
        """Run all tests."""
        print("Performance Testing: AKR Framework")
        print("=" * 50)
        print()
        
        self.setup()
        
        try:
            self.test_query_performance_100()
            self.test_query_performance_1000()
            self.test_staleness_detection_performance()
            self.test_insert_performance()
            self.test_audit_trail_performance()
            self.test_complex_query_performance()
            self.test_index_performance()
        finally:
            self.cleanup()
        
        # Print summary
        print()
        print("=" * 50)
        print("Performance Test Results")
        print("=" * 50)
        print(f"Tests run:    {self.tests_run}")
        print(f"Tests passed: {self.tests_passed}")
        print(f"Tests failed: {self.tests_failed}")
        print()
        
        if self.tests_failed == 0:
            print("✓ All performance targets met!")
            return 0
        else:
            print(f"✗ {self.tests_failed} test(s) failed performance targets")
            return 1

def main():
    import argparse
    parser = argparse.ArgumentParser(description='Performance tests for AKR framework')
    parser.add_argument('--verbose', action='store_true', help='Show detailed output')
    args = parser.parse_args()
    
    runner = PerformanceTestRunner(verbose=args.verbose)
    return runner.run_all()

if __name__ == '__main__':
    sys.exit(main())
