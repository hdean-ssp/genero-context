#!/usr/bin/env python3
"""
sync_akr_db.py - Sync markdown files to SQLite database

Purpose: Parse markdown files from AKR and populate SQLite database

Usage:
    python3 sync_akr_db.py [--full] [--type TYPE] [--artifact NAME]

Options:
    --full         Full sync (rebuild database)
    --type TYPE    Sync only specific type (function, module, file, pattern, issue)
    --artifact NAME Sync specific artifact by name
"""

import sqlite3
import os
import sys
import json
import re
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

def get_akr_base_path():
    """Get AKR base path from environment or use default."""
    akr_path = os.environ.get('GENERO_AKR_BASE_PATH')
    if akr_path:
        return akr_path
    
    brodir = os.environ.get('BRODIR', '/opt/genero')
    return os.path.join(brodir, 'etc', 'genero-akr')

def parse_markdown_metadata(content):
    """Extract metadata from markdown frontmatter."""
    metadata = {}
    
    # Extract Type
    match = re.search(r'\*\*Type:\*\*\s+(\w+)', content)
    if match:
        metadata['type'] = match.group(1)
    
    # Extract Path
    match = re.search(r'\*\*Path:\*\*\s+([^\n]+)', content)
    if match:
        metadata['path'] = match.group(1).strip()
    
    # Extract Status
    match = re.search(r'\*\*Status:\*\*\s+(\w+)', content)
    if match:
        metadata['status'] = match.group(1)
    
    # Extract Updated By
    match = re.search(r'\*\*Updated By:\*\*\s+([^\n]+)', content)
    if match:
        metadata['updated_by'] = match.group(1).strip()
    
    # Extract Last Updated
    match = re.search(r'\*\*Last Updated:\*\*\s+([^\n]+)', content)
    if match:
        metadata['updated_at'] = match.group(1).strip()
    
    return metadata

def parse_markdown_metrics(content):
    """Extract metrics from markdown."""
    metrics = {}
    
    # Extract Metrics section
    match = re.search(r'## Metrics\s*\n(.*?)(?=##|\Z)', content, re.DOTALL)
    if match:
        metrics_text = match.group(1)
        
        # Extract individual metrics
        for line in metrics_text.split('\n'):
            if 'Complexity:' in line:
                m = re.search(r'Complexity:\s*(\d+)', line)
                if m:
                    metrics['complexity'] = int(m.group(1))
            elif 'Lines of Code:' in line:
                m = re.search(r'Lines of Code:\s*(\d+)', line)
                if m:
                    metrics['lines_of_code'] = int(m.group(1))
            elif 'Parameter Count:' in line:
                m = re.search(r'Parameter Count:\s*(\d+)', line)
                if m:
                    metrics['parameter_count'] = int(m.group(1))
            elif 'Dependent Count:' in line:
                m = re.search(r'Dependent Count:\s*(\d+)', line)
                if m:
                    metrics['dependent_count'] = int(m.group(1))
            elif 'Return Count:' in line:
                m = re.search(r'Return Count:\s*(\d+)', line)
                if m:
                    metrics['return_count'] = int(m.group(1))
    
    return metrics

def parse_markdown_findings(content):
    """Extract findings from markdown."""
    findings = []
    
    # Extract Key Findings section
    match = re.search(r'## Key Findings\s*\n(.*?)(?=##|\Z)', content, re.DOTALL)
    if match:
        findings_text = match.group(1)
        for line in findings_text.split('\n'):
            line = line.strip()
            if line.startswith('- '):
                findings.append(line[2:])
    
    return findings

def parse_markdown_issues(content):
    """Extract known issues from markdown."""
    issues = []
    
    # Extract Known Issues section
    match = re.search(r'## Known Issues\s*\n(.*?)(?=##|\Z)', content, re.DOTALL)
    if match:
        issues_text = match.group(1)
        for line in issues_text.split('\n'):
            line = line.strip()
            if line.startswith('- '):
                issues.append(line[2:])
    
    return issues

def parse_markdown_recommendations(content):
    """Extract recommendations from markdown."""
    recommendations = []
    
    # Extract Recommendations section
    match = re.search(r'## Recommendations\s*\n(.*?)(?=##|\Z)', content, re.DOTALL)
    if match:
        recs_text = match.group(1)
        for line in recs_text.split('\n'):
            line = line.strip()
            if line.startswith('- '):
                recommendations.append(line[2:])
    
    return recommendations

def sync_artifact(conn, artifact_name, artifact_type, file_path):
    """Sync a single artifact from markdown to database."""
    if not os.path.exists(file_path):
        return False
    
    try:
        with open(file_path, 'r') as f:
            content = f.read()
        
        # Parse metadata
        metadata = parse_markdown_metadata(content)
        metrics = parse_markdown_metrics(content)
        findings = parse_markdown_findings(content)
        issues = parse_markdown_issues(content)
        recommendations = parse_markdown_recommendations(content)
        
        cursor = conn.cursor()
        
        # Insert or update artifact
        path = metadata.get('path', '')
        status = metadata.get('status', 'active')
        updated_by = metadata.get('updated_by', 'unknown')
        updated_at = metadata.get('updated_at', datetime.utcnow().isoformat() + 'Z')
        
        cursor.execute('''
            INSERT OR REPLACE INTO artifacts (name, type, path, status, updated_by, updated_at)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (artifact_name, artifact_type, path, status, updated_by, updated_at))
        
        artifact_id = cursor.lastrowid
        
        # Insert metrics
        if metrics:
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
        
        # Insert findings
        for finding in findings:
            cursor.execute('''
                INSERT INTO findings (artifact_id, finding, priority)
                VALUES (?, ?, 'MEDIUM')
            ''', (artifact_id, finding))
        
        # Insert issues
        for issue in issues:
            cursor.execute('''
                INSERT INTO issues (artifact_id, issue_type, description)
                VALUES (?, 'KNOWN_ISSUE', ?)
            ''', (artifact_id, issue))
        
        # Insert recommendations
        for rec in recommendations:
            cursor.execute('''
                INSERT INTO recommendations (artifact_id, recommendation, priority)
                VALUES (?, ?, 'MEDIUM')
            ''', (artifact_id, rec))
        
        conn.commit()
        return True
    except Exception as e:
        print(f"[ERROR] Failed to sync {artifact_name}: {e}", file=sys.stderr)
        return False

def sync_all(conn, artifact_type=None):
    """Sync all artifacts from AKR to database."""
    akr_base = get_akr_base_path()
    synced = 0
    failed = 0
    
    # Map types to directories
    type_dirs = {
        'function': 'functions',
        'module': 'modules',
        'file': 'files',
        'pattern': 'patterns',
        'issue': 'issues'
    }
    
    types_to_sync = [artifact_type] if artifact_type else type_dirs.keys()
    
    for atype in types_to_sync:
        if atype not in type_dirs:
            continue
        
        dir_path = os.path.join(akr_base, type_dirs[atype])
        if not os.path.exists(dir_path):
            continue
        
        for md_file in Path(dir_path).glob('*.md'):
            artifact_name = md_file.stem
            if sync_artifact(conn, artifact_name, atype, str(md_file)):
                synced += 1
            else:
                failed += 1
    
    return synced, failed

def main():
    parser = argparse.ArgumentParser(description='Sync AKR markdown to SQLite database')
    parser.add_argument('--full', action='store_true', help='Full sync (rebuild)')
    parser.add_argument('--type', help='Sync only specific type')
    parser.add_argument('--artifact', help='Sync specific artifact')
    args = parser.parse_args()
    
    db_path = get_db_path()
    
    if not os.path.exists(db_path):
        print(f"[ERROR] Database not found: {db_path}", file=sys.stderr)
        print("[ERROR] Run init_akr_db.py first", file=sys.stderr)
        return 1
    
    try:
        conn = sqlite3.connect(db_path)
        
        if args.artifact:
            # Sync specific artifact
            print(f"[INFO] Syncing artifact: {args.artifact}")
            # Try to find it in any type directory
            akr_base = get_akr_base_path()
            found = False
            for atype in ['function', 'module', 'file', 'pattern', 'issue']:
                file_path = os.path.join(akr_base, f"{atype}s", f"{args.artifact}.md")
                if os.path.exists(file_path):
                    if sync_artifact(conn, args.artifact, atype, file_path):
                        print(f"[INFO] Synced {args.artifact}")
                        found = True
                    break
            if not found:
                print(f"[ERROR] Artifact not found: {args.artifact}")
                return 1
        else:
            # Sync all or by type
            synced, failed = sync_all(conn, args.type)
            print(f"[INFO] Sync complete: {synced} synced, {failed} failed")
        
        conn.close()
        return 0
    except Exception as e:
        print(f"[ERROR] Sync failed: {e}", file=sys.stderr)
        return 1

if __name__ == '__main__':
    sys.exit(main())
