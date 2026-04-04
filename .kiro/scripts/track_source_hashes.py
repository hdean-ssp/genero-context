#!/usr/bin/env python3
"""
track_source_hashes.py - Track SHA256 hashes of source files

Purpose: Compute and store hashes of all .4gl files to detect changes

Usage:
    python3 track_source_hashes.py [--force] [--pattern PATTERN]

Options:
    --force         Recompute all hashes (ignore cache)
    --pattern       File pattern to match (default: **/*.4gl)
"""

import hashlib
import json
import os
import sys
import argparse
from pathlib import Path
from datetime import datetime

def get_akr_base_path():
    """Get AKR base path from environment or use default."""
    akr_path = os.environ.get('GENERO_AKR_BASE_PATH')
    if akr_path:
        return akr_path
    
    brodir = os.environ.get('BRODIR', '/opt/genero')
    return os.path.join(brodir, 'etc', 'genero-akr')

def get_source_root():
    """Get source root directory."""
    # Try to find source root (where .4gl files are)
    # Common locations: src/, source/, genero/, current directory
    for candidate in ['src', 'source', 'genero', '.']:
        if os.path.isdir(candidate):
            return candidate
    return '.'

def compute_file_hash(file_path):
    """Compute SHA256 hash of a file."""
    sha256_hash = hashlib.sha256()
    try:
        with open(file_path, 'rb') as f:
            for byte_block in iter(lambda: f.read(4096), b""):
                sha256_hash.update(byte_block)
        return sha256_hash.hexdigest()
    except Exception as e:
        print(f"[ERROR] Failed to hash {file_path}: {e}", file=sys.stderr)
        return None

def load_hashes(hash_file):
    """Load existing hashes from file."""
    if not os.path.exists(hash_file):
        return {}
    
    try:
        with open(hash_file, 'r') as f:
            data = json.load(f)
            return data.get('hashes', {})
    except Exception as e:
        print(f"[WARNING] Failed to load hashes: {e}", file=sys.stderr)
        return {}

def save_hashes(hash_file, hashes):
    """Save hashes to file."""
    try:
        # Ensure directory exists
        os.makedirs(os.path.dirname(hash_file), exist_ok=True)
        
        data = {
            'timestamp': datetime.utcnow().isoformat() + 'Z',
            'hashes': hashes
        }
        
        with open(hash_file, 'w') as f:
            json.dump(data, f, indent=2)
        return True
    except Exception as e:
        print(f"[ERROR] Failed to save hashes: {e}", file=sys.stderr)
        return False

def find_source_files(pattern='**/*.4gl'):
    """Find all source files matching pattern."""
    source_root = get_source_root()
    files = []
    
    try:
        for file_path in Path(source_root).glob(pattern):
            if file_path.is_file():
                files.append(str(file_path))
    except Exception as e:
        print(f"[WARNING] Error finding files: {e}", file=sys.stderr)
    
    return sorted(files)

def track_hashes(force=False, pattern='**/*.4gl'):
    """Track hashes of all source files."""
    akr_base = get_akr_base_path()
    hash_file = os.path.join(akr_base, 'metadata', 'source_hashes.json')
    
    # Load existing hashes
    old_hashes = load_hashes(hash_file) if not force else {}
    new_hashes = {}
    changed_files = []
    new_files = []
    deleted_files = []
    
    # Find all source files
    source_files = find_source_files(pattern)
    
    if not source_files:
        print("[WARNING] No source files found", file=sys.stderr)
        return 0, 0, 0
    
    # Compute hashes for all files
    for file_path in source_files:
        file_hash = compute_file_hash(file_path)
        if file_hash:
            new_hashes[file_path] = file_hash
            
            # Check if file changed
            if file_path in old_hashes:
                if old_hashes[file_path] != file_hash:
                    changed_files.append(file_path)
            else:
                new_files.append(file_path)
    
    # Find deleted files
    for file_path in old_hashes:
        if file_path not in new_hashes:
            deleted_files.append(file_path)
    
    # Save new hashes
    if save_hashes(hash_file, new_hashes):
        print(f"[INFO] Tracked {len(new_hashes)} source files")
        if changed_files:
            print(f"[INFO] Changed: {len(changed_files)} files")
        if new_files:
            print(f"[INFO] New: {len(new_files)} files")
        if deleted_files:
            print(f"[INFO] Deleted: {len(deleted_files)} files")
        return len(changed_files), len(new_files), len(deleted_files)
    else:
        return 0, 0, 0

def main():
    parser = argparse.ArgumentParser(description='Track source file hashes')
    parser.add_argument('--force', action='store_true', help='Recompute all hashes')
    parser.add_argument('--pattern', default='**/*.4gl', help='File pattern to match')
    args = parser.parse_args()
    
    changed, new, deleted = track_hashes(force=args.force, pattern=args.pattern)
    
    # Exit with count of changes
    total_changes = changed + new + deleted
    if total_changes > 0:
        print(f"[INFO] Total changes: {total_changes}")
        return 1  # Exit code 1 means changes detected
    else:
        print("[INFO] No changes detected")
        return 0

if __name__ == '__main__':
    sys.exit(main())
