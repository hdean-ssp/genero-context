# Genero AKR: Knowledge Document Reference

**Purpose**: Reference for knowledge document format, types, and lifecycle. The AKR workflow itself is in `genero-context-workflow.md` (Rules 0, 4, and the AKR Quick Reference section).

**Inclusion**: auto

---

## Knowledge Document Format

All documents follow this structure:

```markdown
# [Artifact Name]

**Type:** file | function | module | pattern | issue
**Path:** [source file path, or N/A]
**Last Updated:** [ISO timestamp]
**Updated By:** [agent ID]
**Status:** active | deprecated | archived

## Summary
[1-2 sentences]

## Key Findings
- [specific, evidence-based finding]

## Metrics
- Complexity: [integer]
- Lines of Code: [integer]
- Parameter Count: [integer]
- Dependent Count: [integer]

## Dependencies
- Calls: [comma-separated list]
- Called By: [comma-separated list]

## Known Issues
- [specific issue with evidence]

## Recommendations
- [HIGH|MEDIUM|LOW]: [specific actionable recommendation]

## Analysis History
| Date | Agent | Action | Notes |
|------|-------|--------|-------|
| 2026-03-31 | agent-1 | initial_analysis | [notes] |

## Raw Data
[Optional: raw genero-tools output]
```

---

## Knowledge Types

| Type | When to create | Key content |
|------|---------------|-------------|
| `function` | Analyzing a specific function | Signature, complexity, dependents, type info |
| `file` | Analyzing an entire .4gl file | All functions, file-level patterns |
| `module` | Analyzing a module | Purpose, key functions, dependencies |
| `pattern` | Recurring code pattern discovered | Where used, variations, anti-patterns |
| `issue` | Problem or tool gap found | Root cause, affected artifacts, workaround |

---

## Findings Quality Rules

**Every finding must be:**
- Objective — based on metrics or source evidence, not opinion
- Specific — "complexity: 12, exceeds recommended 10" not "too complex"
- Actionable — recommendations must be concrete steps

**Never write:**
- "This function is poorly written" → write "complexity: 15, 20 dependents make changes high-risk"
- "Needs improvement" → write "HIGH: Break into 3 functions — complexity exceeds threshold"
- "Type resolution broken" → write "genero-tools cannot resolve LIKE account.* — schema not indexed (tool gap, not code defect)"

---

## Knowledge Lifecycle

```
ACTIVE → UPDATED (new findings appended)
ACTIVE → DEPRECATED (artifact significantly changed, needs re-analysis)
DEPRECATED → ACTIVE (re-analyzed and updated)
ANY → ARCHIVED (artifact removed from codebase)
```

---

## AKR Scripts Reference

```bash
# Retrieve (prints markdown directly — read the output)
bash ~/.kiro/scripts/retrieve_knowledge.sh --type function --name "process_order"
bash ~/.kiro/scripts/retrieve_knowledge.sh --type module --name "ws_webservices"
bash ~/.kiro/scripts/retrieve_knowledge.sh --type file --path "src/orders.4gl"

# Search
bash ~/.kiro/scripts/search_knowledge.sh --query "type resolution"
bash ~/.kiro/scripts/search_knowledge.sh --category issues --query "error"

# Commit
bash ~/.kiro/scripts/commit_knowledge.sh --type function --name "process_order" \
  --findings /tmp/findings.json --action create    # first time
bash ~/.kiro/scripts/commit_knowledge.sh --type function --name "process_order" \
  --findings /tmp/findings.json --action append    # adding to existing
bash ~/.kiro/scripts/commit_knowledge.sh --type function --name "process_order" \
  --findings /tmp/findings.json --action update    # replacing stale knowledge

# Compare before committing
bash ~/.kiro/scripts/compare_knowledge.sh --type function --name "process_order" \
  --findings /tmp/findings.json

# Validate and statistics
bash ~/.kiro/scripts/validate_knowledge.sh
bash ~/.kiro/scripts/get_statistics.sh
```

---

## Logging Tool Gaps

When genero-tools cannot resolve something, investigate the source first, then log the outcome:

```bash
cat > /tmp/gap.json << 'EOF'
{
  "summary": "genero-tools cannot resolve LIKE account.* — schema not indexed",
  "key_findings": [
    "LIKE account.* in process_order, validate_order",
    "account.sch not in genero-tools database",
    "Source confirmed valid — account table exists in production"
  ],
  "metrics": {"complexity": 0, "lines_of_code": 0, "parameter_count": 0, "dependent_count": 0},
  "known_issues": ["Tool gap: account schema not indexed — not a code defect"],
  "recommendations": ["Add account.sch to genero-tools database"]
}
EOF
bash ~/.kiro/scripts/commit_knowledge.sh --type issue --name "tool_gap_account_schema" \
  --findings /tmp/gap.json --action create
```
