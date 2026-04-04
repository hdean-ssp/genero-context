#!/usr/bin/env python3
"""
detect_staleness.py - Detect stale knowledge in AKR

Purpose: Check each AKR entry against staleness thresholds and mark as FRESH, AGING, STALE, or POTENTIALLY_STALE

Usage:
    python3 detect_staleness.py [--type TYPE] [--artifact-name NAME] [--format FORMAT]

Options:
    --type TYPE           Filter by artifact type (function, module, file, pattern, issue)
    --artifact-name NAME  Check specific artifact
    --format FORMAT       Output format: json, text (default: text)
"""

import json
import os
import sys
import argparse
import sqlite3
import yaml
from pathlib import Path
from datetime import datetime, timedelta

def get_db_path():
    """Get database path from environment or use default."""
    db_path = os.environ.get('GENERO_AKR_DB_PATH')
    if db_path:
        return db_path
    
    brodir = os.environ.get('BRODIR', '/opt/genero')
    return os.path.join(brodir, 'etc', 'genero-akr', 'akr.db')

def get_config_path():
    """Get staleness config path."""
    config_path = os.environ.get('GENERO_STALENESS_CONFIG')
    if config_path:
        return config_path
    
    # Try workspace config first
    workspace_config = '.kiro/config/staleness.yaml'
    if os.path.exists(workspace_config):
        return workspace_config
    
    # Try user config
    user_config = os.path.expanduser('~/.kiro/config/staleness.yaml')
    if os.path.exists(user_config):
        return user_config
    
    # Default
    brodir = os.environ.get('BRODIR', '/opt/genero')
    return os.path.join(brodir, 'etc', 'genero-akr', 'staleness.yaml')

def load_config():
    """Load staleness configuration."""
    config_path = get_config_path()
    
    if not os.path.exists(config_path):
        # Return defaults if config not found
        return {
            'staleness_thresholds': {
                'function': {'age_days': 30, 'complexity_threshold': 0.20},
                'module': {'age_days': 60, 'complexity_threshold': 0.25},
                'file': {'age_days': 90, 'complexity_threshold': 0.30},
                'pattern': {'age_days': 120, 'complexity_threshold': 0.50},
                'issue': {'age_days': 90, 'complexity_threshold': 0.0}
            }
        }
    
    try:
        with open(config_path, 'r') as f:
            return yaml.safe_load(f)
    except Exception as e:
        print(f"[WARNING] Failed to load config: {e}", file=sys.stderr)
        return {}

def get_threshold(config, artifact_type):
    """Get staleness threshold for artifact type."""
    thresholds = config.get('staleness_thresholds', {})
    return thresholds.get(artifact_type, {'age_days': 30, 'complexity_threshold': 0.20})

def calculate_days_since_update(updated_at):
    """Calculate days since last update."""
    try:
        # Parse ISO format timestamp
        if isinstance(updated_at, str):
            # Handle both ISO format and other formats
            if 'T' in updated_at:
                dt = datetime.fromisoformat(updated_at.replace('Z', '+00:00'))
            else:
                dt = datetime.fromisoformat(updated_at)
        else:
            dt = updated_at
        
        now = datetime.utcnow()
        delta = now - dt.replace(tzinfo=None)
        return delta.days
    except Exception as e:
        return 0

def check_age_staleness(artifact, threshold):
    """Check if artifact is stale based on age."""
    days_since_update = calculate_days_since_update(artifact['updated_at'])
    age_threshold = threshold.get('age_days', 30)
    
    if days_since_update >= age_threshold:
        return 'STALE', days_since_update
    elif days_since_update >= (age_threshold * 0.8):  # 80% of threshold
        return 'AGING', days_since_update
    else:
        return 'FRESH', days_since_update

def check_complexity_staleness(artifact, current_metrics, stored_metrics, threshold):
    """Check if artifact is stale based on complexity changes."""
    if not stored_metrics or not current_metrics:
        return None
    
    complexity_threshold = threshold.get('complexity_threshold', 0.20)
    
    stored_complexity = stored_metrics.get('complexity', 0)
    current_complexity = current_metrics.get('complexity', 0)
    
    if stored_complexity == 0:
        return None
    
    change_ratio = abs(current_complexity - stored_complexity) / stored_complexity
    
    if change_ratio > complexity_threshold:
        return 'POTENTIALLY_STALE'
    
    return None

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
        print(f"[WARNING] Failed to get metrics: {e}", file=sys.stderr)
        return None

def get_staleness_status(conn, artifact_id):
    """Get current staleness status from database."""
    try:
        cursor = conn.cursor()
        cursor.execute('''
            SELECT status, days_since_update
            FROM staleness
            WHERE artifact_id = ?
        ''', (artifact_id,))
        
        row = cursor.fetchone()
        if row:
            return {'status': row[0], 'days_since_update': row[1]}
        return None
    except Exception as e:
        return None

def update_staleness_status(conn, artifact_id, status, days_since_update):
    """Update staleness status in database."""
    try:
        cursor = conn.cursor()
        cursor.execute('''
            INSERT OR REPLACE INTO staleness
            (artifact_id, status, days_since_update, last_checked)
            VALUES (?, ?, ?, CURRENT_TIMESTAMP)
        ''', (artifact_id, status, days_since_update))
        
        conn.commit()
        return True
    except Exception as e:
        print(f"[WARNING] Failed to update staleness: {e}", file=sys.stderr)
        return False

def detect_staleness(artifact_type=None, artifact_name=None, format_type='text'):
    """Detect stale knowledge in AKR."""
    db_path = get_db_path()
    config = load_config()
    
    if not os.path.exists(db_path):
        if format_type == 'json':
            print(json.dumps({'artifacts': [], 'summary': {'total': 0, 'fresh': 0, 'aging': 0, 'stale': 0, 'potentially_stale': 0}}))
        else:
            print("[INFO] Database not found")
        return 0
    
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Build query
        query = 'SELECT id, name, type, path, status, updated_at FROM artifacts WHERE status = "active"'
        params = []
        
        if artifact_type:
            query += ' AND type = ?'
            params.append(artifact_type)
        
        if artifact_name:
            query += ' AND name = ?'
            params.append(artifact_name)
        
        cursor.execute(query, params)
        artifacts = cursor.fetchall()
        
        results = []
        summary = {'total': 0, 'fresh': 0, 'aging': 0, 'stale': 0, 'potentially_stale': 0}
        
        for artifact in artifacts:
            artifact_id, name, atype, path, status, updated_at = artifact
            summary['total'] += 1
            
            threshold = get_threshold(config, atype)
            
            # Check age-based staleness
            age_status, days_since_update = check_age_staleness(
                {'updated_at': updated_at},
                threshold
            )
            
            # Check complexity-based staleness
            current_metrics = get_artifact_metrics(conn, artifact_id)
            stored_status = get_staleness_status(conn, artifact_id)
            stored_metrics = stored_status.get('metrics') if stored_status else None
            
            complexity_status = check_complexity_staleness(
                {'id': artifact_id},
                current_metrics,
                stored_metrics,
                threshold
            )
            
            # Determine final status
            final_status = age_status
            reason = f"Age: {days_since_update} days"
            
            if complexity_status == 'POTENTIALLY_STALE':
                final_status = 'POTENTIALLY_STALE'
                reason = "Complexity changed significantly"
            
            # Update database
            update_staleness_status(conn, artifact_id, final_status, days_since_update)
            
            # Track summary
            if final_status == 'FRESH':
                summary['fresh'] += 1
            elif final_status == 'AGING':
                summary['aging'] += 1
            elif final_status == 'STALE':
                summary['stale'] += 1
            elif final_status == 'POTENTIALLY_STALE':
                summary['potentially_stale'] += 1
            
            results.append({
                'id': artifact_id,
                'name': name,
                'type': atype,
                'path': path,
                'status': final_status,
                'days_since_update': days_since_update,
                'threshold': threshold.get('age_days', 30),
                'reason': reason
            })
        
        conn.close()
        
        # Output results
        if format_type == 'json':
            output = {
                'timestamp': datetime.utcnow().isoformat() + 'Z',
                'artifacts': results,
                'summary': summary
            }
            print(json.dumps(output, indent=2))
        else:
            print(f"[INFO] Staleness Detection Results")
            print(f"[INFO] Total artifacts: {summary['total']}")
            print(f"[INFO] FRESH: {summary['fresh']}")
            print(f"[INFO] AGING: {summary['aging']}")
            print(f"[INFO] STALE: {summary['stale']}")
            print(f"[INFO] POTENTIALLY_STALE: {summary['potentially_stale']}")
            print()
            
            if results:
                for result in results:
                    if result['status'] != 'FRESH':
                        print(f"  {result['name']} ({result['type']}): {result['status']} - {result['reason']}")
        
        return len([r for r in results if r['status'] in ['STALE', 'POTENTIALLY_STALE']])
    
    except Exception as e:
        print(f"[ERROR] Failed to detect staleness: {e}", file=sys.stderr)
        return 1

def main():
    parser = argparse.ArgumentParser(description='Detect stale knowledge in AKR')
    parser.add_argument('--type', dest='artifact_type', help='Filter by artifact type')
    parser.add_argument('--artifact-name', help='Check specific artifact')
    parser.add_argument('--format', choices=['json', 'text'], default='text', help='Output format')
    args = parser.parse_args()
    
    stale_count = detect_staleness(
        artifact_type=args.artifact_type,
        artifact_name=args.artifact_name,
        format_type=args.format
    )
    
    return 0 if stale_count == 0 else 1

if __name__ == '__main__':
    sys.exit(main())
