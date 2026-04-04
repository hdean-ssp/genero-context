#!/usr/bin/env python3
"""
query_akr.py - Query AKR database with SQL interface

Purpose: Query SQLite database with pre-built and custom queries

Usage:
    python3 query_akr.py [--high-complexity] [--high-risk] [--stale] [--recent] [--type TYPE] [--sql SQL] [--format FORMAT] [--limit N]

Options:
    --high-complexity  Find high-complexity functions (complexity > 10)
    --high-risk        Find high-risk functions (complexity > 10 OR dependents > 15)
    --stale            Find stale knowledge
    --recent           Find recently modified artifacts
    --type TYPE        Filter by artifact type
    --sql SQL          Custom SQL query
    --format FORMAT    Output format: json, csv, text (default: text)
    --limit N          Limit results to N rows
    --filter FILTER    Additional WHERE clause
"""

import sqlite3
import os
import sys
import json
import csv
import argparse
from pathlib import Path

def get_db_path():
    """Get database path from environment or use default."""
    db_path = os.environ.get('GENERO_AKR_DB_PATH')
    if db_path:
        return db_path
    
    brodir = os.environ.get('BRODIR', '/opt/genero')
    return os.path.join(brodir, 'etc', 'genero-akr', 'akr.db')

def format_text(rows, columns):
    """Format results as text table."""
    if not rows:
        print("No results")
        return
    
    # Calculate column widths
    widths = [len(col) for col in columns]
    for row in rows:
        for i, val in enumerate(row):
            widths[i] = max(widths[i], len(str(val)))
    
    # Print header
    header = " | ".join(col.ljust(widths[i]) for i, col in enumerate(columns))
    print(header)
    print("-" * len(header))
    
    # Print rows
    for row in rows:
        print(" | ".join(str(val).ljust(widths[i]) for i, val in enumerate(row)))

def format_json(rows, columns):
    """Format results as JSON."""
    results = []
    for row in rows:
        results.append(dict(zip(columns, row)))
    print(json.dumps(results, indent=2))

def format_csv(rows, columns):
    """Format results as CSV."""
    writer = csv.writer(sys.stdout)
    writer.writerow(columns)
    writer.writerows(rows)

def execute_query(conn, query, params=None, limit=None, format_type='text'):
    """Execute query and format results."""
    try:
        cursor = conn.cursor()
        
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        
        columns = [description[0] for description in cursor.description]
        rows = cursor.fetchall()
        
        if limit:
            rows = rows[:limit]
        
        # Format output
        if format_type == 'json':
            format_json(rows, columns)
        elif format_type == 'csv':
            format_csv(rows, columns)
        else:
            format_text(rows, columns)
        
        return 0
    except Exception as e:
        print(f"[ERROR] Query failed: {e}", file=sys.stderr)
        return 1

def main():
    parser = argparse.ArgumentParser(description='Query AKR database')
    parser.add_argument('--high-complexity', action='store_true', help='Find high-complexity functions')
    parser.add_argument('--high-risk', action='store_true', help='Find high-risk functions')
    parser.add_argument('--stale', action='store_true', help='Find stale knowledge')
    parser.add_argument('--recent', action='store_true', help='Find recently modified')
    parser.add_argument('--type', help='Filter by artifact type')
    parser.add_argument('--sql', help='Custom SQL query')
    parser.add_argument('--format', choices=['json', 'csv', 'text'], default='text', help='Output format')
    parser.add_argument('--limit', type=int, help='Limit results')
    parser.add_argument('--filter', help='Additional WHERE clause')
    args = parser.parse_args()
    
    db_path = get_db_path()
    
    if not os.path.exists(db_path):
        print(f"[ERROR] Database not found: {db_path}", file=sys.stderr)
        return 1
    
    try:
        conn = sqlite3.connect(db_path)
        
        if args.sql:
            # Custom SQL query
            return execute_query(conn, args.sql, limit=args.limit, format_type=args.format)
        
        elif args.high_complexity:
            query = 'SELECT * FROM high_complexity_functions'
            if args.filter:
                query += f' WHERE {args.filter}'
            return execute_query(conn, query, limit=args.limit, format_type=args.format)
        
        elif args.high_risk:
            query = 'SELECT * FROM high_risk_functions'
            if args.filter:
                query += f' WHERE {args.filter}'
            return execute_query(conn, query, limit=args.limit, format_type=args.format)
        
        elif args.stale:
            query = 'SELECT * FROM stale_knowledge'
            if args.filter:
                query += f' WHERE {args.filter}'
            return execute_query(conn, query, limit=args.limit, format_type=args.format)
        
        elif args.recent:
            query = 'SELECT * FROM recent_changes'
            if args.filter:
                query += f' WHERE {args.filter}'
            return execute_query(conn, query, limit=args.limit, format_type=args.format)
        
        elif args.type:
            query = 'SELECT * FROM artifacts WHERE type = ?'
            if args.filter:
                query += f' AND {args.filter}'
            return execute_query(conn, query, params=(args.type,), limit=args.limit, format_type=args.format)
        
        else:
            # Default: show all artifacts
            query = 'SELECT * FROM artifacts'
            if args.filter:
                query += f' WHERE {args.filter}'
            return execute_query(conn, query, limit=args.limit, format_type=args.format)
        
    except Exception as e:
        print(f"[ERROR] Failed: {e}", file=sys.stderr)
        return 1

if __name__ == '__main__':
    sys.exit(main())
