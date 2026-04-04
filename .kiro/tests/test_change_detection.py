#!/usr/bin/env python3
"""
test_change_detection.py - Test Phase 3 change detection implementation

Purpose: Verify source hash tracking and change detection functionality

Usage:
    python3 test_change_detection.py [--verbose]
"""

import os
import sys
import tempfile
import json
from pathlib import Path
from datetime import datetime

# Add scripts to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'scripts'))

from track_source_hashes import compute_file_hash, load_hashes, save_hashes

class TestRunner:
    def __init__(self, verbose=False):
        self.verbose = verbose
        self.tests_run = 0
        self.tests_passed = 0
        self.tests_failed = 0
        self.test_dir = None
        self.hash_file = None
    
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
        self.hash_file = os.path.join(self.test_dir, 'hashes.json')
    
    def cleanup(self):
        """Cleanup test environment."""
        if self.test_dir and os.path.exists(self.test_dir):
            import shutil
            shutil.rmtree(self.test_dir)
    
    def test_compute_hash(self):
        """Test hash computation."""
        self.test_start("Compute file hash")
        try:
            # Create test file
            test_file = os.path.join(self.test_dir, 'test.4gl')
            with open(test_file, 'w') as f:
                f.write('FUNCTION test_func()\nEND FUNCTION\n')
            
            # Compute hash
            file_hash = compute_file_hash(test_file)
            
            if file_hash and len(file_hash) == 64:  # SHA256 is 64 hex chars
                self.test_pass()
            else:
                self.test_fail(f"Invalid hash: {file_hash}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_hash_consistency(self):
        """Test that same file produces same hash."""
        self.test_start("Hash consistency")
        try:
            test_file = os.path.join(self.test_dir, 'test.4gl')
            with open(test_file, 'w') as f:
                f.write('FUNCTION test_func()\nEND FUNCTION\n')
            
            hash1 = compute_file_hash(test_file)
            hash2 = compute_file_hash(test_file)
            
            if hash1 == hash2:
                self.test_pass()
            else:
                self.test_fail(f"Hashes differ: {hash1} vs {hash2}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_hash_change_detection(self):
        """Test that file changes produce different hash."""
        self.test_start("Hash change detection")
        try:
            test_file = os.path.join(self.test_dir, 'test.4gl')
            
            # Create file and compute hash
            with open(test_file, 'w') as f:
                f.write('FUNCTION test_func()\nEND FUNCTION\n')
            hash1 = compute_file_hash(test_file)
            
            # Modify file and compute hash
            with open(test_file, 'w') as f:
                f.write('FUNCTION test_func()\n  RETURN 1\nEND FUNCTION\n')
            hash2 = compute_file_hash(test_file)
            
            if hash1 != hash2:
                self.test_pass()
            else:
                self.test_fail("Hashes should differ after modification")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_save_hashes(self):
        """Test saving hashes to file."""
        self.test_start("Save hashes to file")
        try:
            hashes = {
                'src/test1.4gl': 'abc123',
                'src/test2.4gl': 'def456'
            }
            
            if save_hashes(self.hash_file, hashes):
                self.test_pass()
            else:
                self.test_fail("Failed to save hashes")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_load_hashes(self):
        """Test loading hashes from file."""
        self.test_start("Load hashes from file")
        try:
            # Save hashes
            hashes = {
                'src/test1.4gl': 'abc123',
                'src/test2.4gl': 'def456'
            }
            save_hashes(self.hash_file, hashes)
            
            # Load hashes
            loaded = load_hashes(self.hash_file)
            
            if loaded == hashes:
                self.test_pass()
            else:
                self.test_fail(f"Loaded hashes don't match: {loaded}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_hash_file_format(self):
        """Test hash file format."""
        self.test_start("Hash file format")
        try:
            hashes = {
                'src/test1.4gl': 'abc123',
                'src/test2.4gl': 'def456'
            }
            save_hashes(self.hash_file, hashes)
            
            # Verify file format
            with open(self.hash_file, 'r') as f:
                data = json.load(f)
            
            if 'timestamp' in data and 'hashes' in data:
                self.test_pass()
            else:
                self.test_fail("Invalid file format")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_empty_hashes(self):
        """Test handling of empty hashes."""
        self.test_start("Empty hashes handling")
        try:
            loaded = load_hashes(os.path.join(self.test_dir, 'nonexistent.json'))
            
            if loaded == {}:
                self.test_pass()
            else:
                self.test_fail(f"Expected empty dict, got {loaded}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_multiple_files(self):
        """Test tracking multiple files."""
        self.test_start("Track multiple files")
        try:
            # Create multiple test files
            files = {}
            for i in range(5):
                test_file = os.path.join(self.test_dir, f'test{i}.4gl')
                with open(test_file, 'w') as f:
                    f.write(f'FUNCTION test_func{i}()\nEND FUNCTION\n')
                files[test_file] = compute_file_hash(test_file)
            
            # Save and load
            save_hashes(self.hash_file, files)
            loaded = load_hashes(self.hash_file)
            
            if len(loaded) == 5:
                self.test_pass()
            else:
                self.test_fail(f"Expected 5 files, got {len(loaded)}")
        except Exception as e:
            self.test_fail(str(e))
    
    def test_hash_persistence(self):
        """Test that hashes persist across saves."""
        self.test_start("Hash persistence")
        try:
            # Save hashes
            hashes1 = {'src/test1.4gl': 'abc123'}
            save_hashes(self.hash_file, hashes1)
            
            # Load and verify
            loaded1 = load_hashes(self.hash_file)
            
            # Save different hashes
            hashes2 = {'src/test2.4gl': 'def456'}
            save_hashes(self.hash_file, hashes2)
            
            # Load and verify
            loaded2 = load_hashes(self.hash_file)
            
            if loaded1 == hashes1 and loaded2 == hashes2:
                self.test_pass()
            else:
                self.test_fail("Hashes not persisted correctly")
        except Exception as e:
            self.test_fail(str(e))
    
    def run_all(self):
        """Run all tests."""
        print("Testing Phase 3: Change Detection")
        print("=" * 50)
        print()
        
        self.setup()
        
        try:
            self.test_compute_hash()
            self.test_hash_consistency()
            self.test_hash_change_detection()
            self.test_save_hashes()
            self.test_load_hashes()
            self.test_hash_file_format()
            self.test_empty_hashes()
            self.test_multiple_files()
            self.test_hash_persistence()
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
    parser = argparse.ArgumentParser(description='Test Phase 3 change detection')
    parser.add_argument('--verbose', action='store_true', help='Show detailed output')
    args = parser.parse_args()
    
    runner = TestRunner(verbose=args.verbose)
    return runner.run_all()

if __name__ == '__main__':
    sys.exit(main())
