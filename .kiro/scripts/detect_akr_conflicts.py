#!/usr/bin/env python3
"""
detect_akr_conflicts.py - Detect concurrent write conflicts in AKR

Purpose: Find artifacts modified by multiple agents

Usage:
    python3 detect_akr_conflicts.py [--since HOURS] [--format FORMAT]

Options:
    --since HOURS   Look back N hours (default: 1)
    --format FORMAT Output format: json, text (default: text)
"""

import sqlite3
import os
import sys
import json
import argparse
from datetime import datetime, timedelta

def get_db_path():
    """Get database path from environment or use default."""
    db_path = os.environ.get('GENERO_AKR_DB_PATH')
    if db_path:
        return db_path
    
    brodir = os.environ.get('BRODIR', '/opt/genero')
    return os.path.join(brodir, 'etc', 'genero-akr', 'akr.db')

def detect_conflicts(conn, hours=1, format_type='text'):
    """Detect artifacts modified by multiple agents."""
    try:
        cursor = conn.cursor()
        
        # Calculate time window
        cutoff_time = (datetime.utcnow() - timedelta(hours=hours)).isoformat() + 'Z'
        
        # Find artifacts modified by multiple agents
        query = '''
            SELECT 
                a.id,
                a.name,
                a.type,
                COUNT(DISTINCT a.updated_by) as agent_count,
                COUNT(*) as modification_count,
                MAX(a.updated_at) as last_modified
            FROM artifacts a
            WHERE a.updated_at > ?
            GROUP BY a.id, a.name, a.type
            HAVING COUNT(DISTINCT a.updated_by) > 1
            ORDER BY modification_count DESC
        '''
        
        cursor.execute(query, (cutoff_time,))
        rows = cursor.fetchall()
        
        if not rows:
            if format_type == 'json':
                print(json.dumps([], indent=2))
            else:
                print("No conflicts detected")
            return 0
        
        if format_type == 'json':
            results = []
            for row in rows:
                results.append({
                    'id': row[0],
                    'name': row[1],
                    'type': row[2],
                    'agent_count': row[3],
                    'modification_count': row[4],
                    'last_modified': row[5]
                })
            print(json.dumps(results, indent=2))
        else:
            # Text format
            print(f"Conflicts detected in last {hours} hour(s):")
            print("-" * 80)
            print(f"{'Name':<30} {'Type':<10} {'Agents':<8} {'Mods':<6} {'Last Modified':<20}")
            print("-" * 80)
            for row in rows:
                name = row[1][:29]
                atype = row[2][:9]
                agents = str(row[3])
                mods = str(row[4])
                last_mod = row[5][:19] if row[5] else 'N/A'
                print(f"{name:<30} {atype:<10} {agents:<8} {mods:<6} {last_mod:<20}")
        
        return 0
    except Exception as e:
        print(f"[ERROR] Conflict detection failed: {e}", file=sys.stderr)
        return 1

def main():
    parser = argparse.ArgumentParser(description='Detect concurrent write conflicts in AKR')
    parser.add_argument('--since', type=int, default=1, help='Look back N hours')
    parser.add_argument('--format', choices=['json', 'text'], default='text', help='Output format')
    args = parser.parse_args()
    
    db_path = get_db_path()
    
    if not os.path.exists(db_path):
        print(f"[ERROR] Database not found: {db_path}", file=sys.stderr)
        return 1
    
    try:
        conn = sqlite3.connect(db_path)
        return detect_conflicts(conn, hours=args.since, format_type=args.format)
    except Exception as e:
        print(f"[ERROR] Failed: {e}", file=sys.stderr)
        return 1

if __name__ == '__main__':
    sys.exit(main())
