#!/usr/bin/env python3
"""
detect_source_changes.py - Detect source code changes and mark stale knowledge

Purpose: Compare current source hashes with stored hashes, identify affected functions,
and mark related AKR entries as potentially stale

Usage:
    python3 detect_source_changes.py [--since HOURS] [--format FORMAT]

Options:
    --since HOURS   Look back N hours (default: 24)
    --format FORMAT Output format: json, text (default: text)
"""

import json
import os
import sys
import argparse
import sqlite3
from pathlib import Path
from datetime import datetime, timedelta
from hashlib import sha256

def get_akr_base_path():
    """Get AKR base path from environment or use default."""
    akr_path = os.environ.get('GENERO_AKR_BASE_PATH')
    if akr_path:
        return akr_path
    
    brodir = os.environ.get('BRODIR', '/opt/genero')
    return os.path.join(brodir, 'etc', 'genero-akr')

def get_db_path():
    """Get database path from environment or use default."""
    db_path = os.environ.get('GENERO_AKR_DB_PATH')
    if db_path:
        return db_path
    
    brodir = os.environ.get('BRODIR', '/opt/genero')
    return os.path.join(brodir, 'etc', 'genero-akr', 'akr.db')

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

def compute_file_hash(file_path):
    """Compute SHA256 hash of a file."""
    sha256_hash = sha256()
    try:
        with open(file_path, 'rb') as f:
            for byte_block in iter(lambda: f.read(4096), b""):
                sha256_hash.update(byte_block)
        return sha256_hash.hexdigest()
    except Exception as e:
        return None

def find_affected_artifacts(conn, file_path):
    """Find artifacts affected by a changed file."""
    try:
        cursor = conn.cursor()
        
        # Find artifacts with matching path
        cursor.execute(
            "SELECT id, name, type FROM artifacts WHERE path = ? OR path LIKE ?",
            (file_path, f"%{file_path}%")
        )
        
        artifacts = []
        for row in cursor.fetchall():
            artifacts.append({
                'id': row[0],
                'name': row[1],
                'type': row[2]
            })
        
        return artifacts
    except Exception as e:
        print(f"[WARNING] Failed to find affected artifacts: {e}", file=sys.stderr)
        return []

def mark_stale(conn, artifact_id):
    """Mark an artifact as potentially stale."""
    try:
        cursor = conn.cursor()
        
        # Update staleness table
        cursor.execute('''
            INSERT OR REPLACE INTO staleness 
            (artifact_id, status, days_since_update, last_checked)
            VALUES (?, 'POTENTIALLY_STALE', 0, CURRENT_TIMESTAMP)
        ''', (artifact_id,))
        
        conn.commit()
        return True
    except Exception as e:
        print(f"[WARNING] Failed to mark stale: {e}", file=sys.stderr)
        return False

def detect_changes(since_hours=24, format_type='text'):
    """Detect source code changes and mark stale knowledge."""
    akr_base = get_akr_base_path()
    hash_file = os.path.join(akr_base, 'metadata', 'source_hashes.json')
    db_path = get_db_path()
    
    # Load stored hashes
    stored_hashes = load_hashes(hash_file)
    
    if not stored_hashes:
        if format_type == 'json':
            print(json.dumps({'changes': [], 'affected_artifacts': []}, indent=2))
        else:
            print("[INFO] No stored hashes found")
        return 0
    
    # Find changed files
    changed_files = []
    affected_artifacts = []
    
    for file_path, stored_hash in stored_hashes.items():
        if os.path.exists(file_path):
            current_hash = compute_file_hash(file_path)
            if current_hash and current_hash != stored_hash:
                changed_files.append(file_path)
        else:
            # File was deleted
            changed_files.append(file_path)
    
    # If database exists, mark affected artifacts as stale
    if os.path.exists(db_path):
        try:
            conn = sqlite3.connect(db_path)
            
            for file_path in changed_files:
                artifacts = find_affected_artifacts(conn, file_path)
                for artifact in artifacts:
                    if mark_stale(conn, artifact['id']):
                        affected_artifacts.append({
                            'file': file_path,
                            'artifact_id': artifact['id'],
                            'artifact_name': artifact['name'],
                            'artifact_type': artifact['type']
                        })
            
            conn.close()
        except Exception as e:
            print(f"[WARNING] Failed to update database: {e}", file=sys.stderr)
    
    # Output results
    if format_type == 'json':
        results = {
            'timestamp': datetime.utcnow().isoformat() + 'Z',
            'changed_files': changed_files,
            'affected_artifacts': affected_artifacts,
            'change_count': len(changed_files),
            'artifact_count': len(affected_artifacts)
        }
        print(json.dumps(results, indent=2))
    else:
        print(f"[INFO] Detected {len(changed_files)} changed file(s)")
        for file_path in changed_files:
            print(f"  - {file_path}")
        
        if affected_artifacts:
            print(f"[INFO] Marked {len(affected_artifacts)} artifact(s) as stale")
            for artifact in affected_artifacts:
                print(f"  - {artifact['artifact_name']} ({artifact['artifact_type']})")
    
    return len(changed_files)

def main():
    parser = argparse.ArgumentParser(description='Detect source code changes')
    parser.add_argument('--since', type=int, default=24, help='Look back N hours')
    parser.add_argument('--format', choices=['json', 'text'], default='text', help='Output format')
    args = parser.parse_args()
    
    changes = detect_changes(since_hours=args.since, format_type=args.format)
    
    # Exit with count of changes
    if changes > 0:
        return 1  # Exit code 1 means changes detected
    else:
        return 0

if __name__ == '__main__':
    sys.exit(main())
