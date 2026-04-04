#!/usr/bin/env python3
"""
staleness_report.py - Generate staleness metrics and reports

Purpose: Aggregate staleness status, show refresh recommendations, generate reports

Usage:
    python3 staleness_report.py [--format FORMAT] [--output FILE]

Options:
    --format FORMAT   Output format: text, json, csv, html (default: text)
    --output FILE     Write to file instead of stdout
"""

import json
import os
import sys
import argparse
import sqlite3
from datetime import datetime
from collections import defaultdict

def get_db_path():
    """Get database path from environment or use default."""
    db_path = os.environ.get('GENERO_AKR_DB_PATH')
    if db_path:
        return db_path
    
    brodir = os.environ.get('BRODIR', '/opt/genero')
    return os.path.join(brodir, 'etc', 'genero-akr', 'akr.db')

def count_by_status(conn):
    """Count artifacts by staleness status."""
    try:
        cursor = conn.cursor()
        cursor.execute('''
            SELECT s.status, COUNT(*) as count
            FROM staleness s
            JOIN artifacts a ON s.artifact_id = a.id
            WHERE a.status = 'active'
            GROUP BY s.status
        ''')
        
        results = {}
        total = 0
        for row in cursor.fetchall():
            status, count = row
            results[status] = count
            total += count
        
        return results, total
    except Exception as e:
        print(f"[WARNING] Failed to count by status: {e}", file=sys.stderr)
        return {}, 0

def count_by_type(conn):
    """Count artifacts by type."""
    try:
        cursor = conn.cursor()
        cursor.execute('''
            SELECT a.type, COUNT(*) as count
            FROM artifacts a
            WHERE a.status = 'active'
            GROUP BY a.type
        ''')
        
        results = {}
        for row in cursor.fetchall():
            atype, count = row
            results[atype] = count
        
        return results
    except Exception as e:
        return {}

def find_high_risk_stale(conn, limit=10):
    """Find high-risk stale artifacts (stale + high complexity)."""
    try:
        cursor = conn.cursor()
        cursor.execute('''
            SELECT a.id, a.name, a.type, m.complexity, m.dependent_count, s.days_since_update
            FROM artifacts a
            JOIN metrics m ON a.id = m.artifact_id
            JOIN staleness s ON a.id = s.artifact_id
            WHERE s.status IN ('STALE', 'POTENTIALLY_STALE')
            AND a.status = 'active'
            AND (m.complexity > 10 OR m.dependent_count > 15)
            ORDER BY m.complexity DESC, m.dependent_count DESC
            LIMIT ?
        ''', (limit,))
        
        results = []
        for row in cursor.fetchall():
            results.append({
                'id': row[0],
                'name': row[1],
                'type': row[2],
                'complexity': row[3],
                'dependent_count': row[4],
                'days_since_update': row[5]
            })
        
        return results
    except Exception as e:
        print(f"[WARNING] Failed to find high-risk stale: {e}", file=sys.stderr)
        return []

def get_age_distribution(conn):
    """Get distribution of artifact ages."""
    try:
        cursor = conn.cursor()
        cursor.execute('''
            SELECT 
                CASE 
                    WHEN s.days_since_update <= 7 THEN '0-7 days'
                    WHEN s.days_since_update <= 14 THEN '8-14 days'
                    WHEN s.days_since_update <= 30 THEN '15-30 days'
                    WHEN s.days_since_update <= 60 THEN '31-60 days'
                    WHEN s.days_since_update <= 90 THEN '61-90 days'
                    ELSE '90+ days'
                END as age_range,
                COUNT(*) as count
            FROM staleness s
            JOIN artifacts a ON s.artifact_id = a.id
            WHERE a.status = 'active'
            GROUP BY age_range
            ORDER BY s.days_since_update
        ''')
        
        results = {}
        for row in cursor.fetchall():
            results[row[0]] = row[1]
        
        return results
    except Exception as e:
        return {}

def generate_text_report(conn):
    """Generate text format report."""
    status_counts, total = count_by_status(conn)
    type_counts = count_by_type(conn)
    high_risk = find_high_risk_stale(conn, limit=10)
    age_dist = get_age_distribution(conn)
    
    lines = []
    lines.append("=" * 70)
    lines.append("AKR STALENESS REPORT")
    lines.append("=" * 70)
    lines.append(f"Generated: {datetime.utcnow().isoformat()}Z")
    lines.append("")
    
    # Summary
    lines.append("SUMMARY")
    lines.append("-" * 70)
    lines.append(f"Total Artifacts: {total}")
    
    for status in ['FRESH', 'AGING', 'STALE', 'POTENTIALLY_STALE']:
        count = status_counts.get(status, 0)
        pct = (count / total * 100) if total > 0 else 0
        lines.append(f"  {status:20s}: {count:4d} ({pct:5.1f}%)")
    
    lines.append("")
    
    # By Type
    lines.append("BY ARTIFACT TYPE")
    lines.append("-" * 70)
    for atype, count in sorted(type_counts.items()):
        lines.append(f"  {atype:20s}: {count:4d}")
    
    lines.append("")
    
    # Age Distribution
    lines.append("AGE DISTRIBUTION")
    lines.append("-" * 70)
    for age_range, count in age_dist.items():
        lines.append(f"  {age_range:20s}: {count:4d}")
    
    lines.append("")
    
    # High Risk
    if high_risk:
        lines.append("HIGH-RISK STALE ARTIFACTS (Top 10)")
        lines.append("-" * 70)
        for artifact in high_risk:
            lines.append(f"  {artifact['name']:30s} ({artifact['type']:10s})")
            lines.append(f"    Complexity: {artifact['complexity']}, Dependents: {artifact['dependent_count']}, Age: {artifact['days_since_update']} days")
    
    lines.append("")
    lines.append("=" * 70)
    
    return "\n".join(lines)

def generate_json_report(conn):
    """Generate JSON format report."""
    status_counts, total = count_by_status(conn)
    type_counts = count_by_type(conn)
    high_risk = find_high_risk_stale(conn, limit=10)
    age_dist = get_age_distribution(conn)
    
    report = {
        'timestamp': datetime.utcnow().isoformat() + 'Z',
        'summary': {
            'total_artifacts': total,
            'status_distribution': status_counts,
            'type_distribution': type_counts
        },
        'age_distribution': age_dist,
        'high_risk_stale': high_risk
    }
    
    return json.dumps(report, indent=2)

def generate_csv_report(conn):
    """Generate CSV format report."""
    try:
        cursor = conn.cursor()
        cursor.execute('''
            SELECT a.name, a.type, s.status, s.days_since_update, m.complexity, m.dependent_count
            FROM artifacts a
            JOIN staleness s ON a.id = s.artifact_id
            LEFT JOIN metrics m ON a.id = m.artifact_id
            WHERE a.status = 'active'
            ORDER BY s.days_since_update DESC
        ''')
        
        lines = []
        lines.append("Name,Type,Status,Days Since Update,Complexity,Dependent Count")
        
        for row in cursor.fetchall():
            name, atype, status, days, complexity, dependents = row
            complexity = complexity or 0
            dependents = dependents or 0
            lines.append(f'"{name}","{atype}","{status}",{days},{complexity},{dependents}')
        
        return "\n".join(lines)
    except Exception as e:
        print(f"[WARNING] Failed to generate CSV: {e}", file=sys.stderr)
        return ""

def generate_html_report(conn):
    """Generate HTML format report."""
    status_counts, total = count_by_status(conn)
    type_counts = count_by_type(conn)
    high_risk = find_high_risk_stale(conn, limit=10)
    age_dist = get_age_distribution(conn)
    
    html = []
    html.append("<!DOCTYPE html>")
    html.append("<html>")
    html.append("<head>")
    html.append("<title>AKR Staleness Report</title>")
    html.append("<style>")
    html.append("body { font-family: Arial, sans-serif; margin: 20px; }")
    html.append("h1 { color: #333; }")
    html.append("table { border-collapse: collapse; width: 100%; margin: 20px 0; }")
    html.append("th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }")
    html.append("th { background-color: #4CAF50; color: white; }")
    html.append("tr:nth-child(even) { background-color: #f2f2f2; }")
    html.append(".fresh { color: green; }")
    html.append(".aging { color: orange; }")
    html.append(".stale { color: red; }")
    html.append(".potentially_stale { color: darkred; }")
    html.append("</style>")
    html.append("</head>")
    html.append("<body>")
    
    html.append(f"<h1>AKR Staleness Report</h1>")
    html.append(f"<p>Generated: {datetime.utcnow().isoformat()}Z</p>")
    
    # Summary
    html.append("<h2>Summary</h2>")
    html.append("<table>")
    html.append("<tr><th>Status</th><th>Count</th><th>Percentage</th></tr>")
    
    for status in ['FRESH', 'AGING', 'STALE', 'POTENTIALLY_STALE']:
        count = status_counts.get(status, 0)
        pct = (count / total * 100) if total > 0 else 0
        css_class = status.lower().replace('_', '')
        html.append(f"<tr><td class='{css_class}'>{status}</td><td>{count}</td><td>{pct:.1f}%</td></tr>")
    
    html.append("</table>")
    
    # High Risk
    if high_risk:
        html.append("<h2>High-Risk Stale Artifacts</h2>")
        html.append("<table>")
        html.append("<tr><th>Name</th><th>Type</th><th>Complexity</th><th>Dependents</th><th>Age (days)</th></tr>")
        
        for artifact in high_risk:
            html.append(f"<tr>")
            html.append(f"<td>{artifact['name']}</td>")
            html.append(f"<td>{artifact['type']}</td>")
            html.append(f"<td>{artifact['complexity']}</td>")
            html.append(f"<td>{artifact['dependent_count']}</td>")
            html.append(f"<td>{artifact['days_since_update']}</td>")
            html.append(f"</tr>")
        
        html.append("</table>")
    
    html.append("</body>")
    html.append("</html>")
    
    return "\n".join(html)

def generate_report(format_type='text', output_file=None):
    """Generate staleness report."""
    db_path = get_db_path()
    
    if not os.path.exists(db_path):
        print("[INFO] Database not found")
        return 1
    
    try:
        conn = sqlite3.connect(db_path)
        
        # Generate report based on format
        if format_type == 'json':
            report = generate_json_report(conn)
        elif format_type == 'csv':
            report = generate_csv_report(conn)
        elif format_type == 'html':
            report = generate_html_report(conn)
        else:
            report = generate_text_report(conn)
        
        conn.close()
        
        # Output report
        if output_file:
            with open(output_file, 'w') as f:
                f.write(report)
            print(f"[INFO] Report written to {output_file}")
        else:
            print(report)
        
        return 0
    
    except Exception as e:
        print(f"[ERROR] Failed to generate report: {e}", file=sys.stderr)
        return 1

def main():
    parser = argparse.ArgumentParser(description='Generate staleness report')
    parser.add_argument('--format', choices=['text', 'json', 'csv', 'html'], default='text', help='Output format')
    parser.add_argument('--output', help='Write to file')
    args = parser.parse_args()
    
    return generate_report(format_type=args.format, output_file=args.output)

if __name__ == '__main__':
    sys.exit(main())
