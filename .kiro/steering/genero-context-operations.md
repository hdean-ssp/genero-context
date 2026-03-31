# Genero Context Framework: Operations & Troubleshooting

**Purpose**: Error handling, fallback strategies, and AKR error logging

**Inclusion**: auto

---

## AKR Error Logging

Log significant errors to the AKR so future agents don't rediscover them.

**Log when**: genero-tools fails repeatedly, a script blocks progress, a permission issue is encountered, or a tool gap is confirmed.
**Don't log**: one-off timeouts or transient errors.

```bash
cat > /tmp/error_findings.json << 'EOF'
{
  "summary": "Brief description",
  "key_findings": ["Error: [message]", "Context: [what was attempted]", "Impact: [what it blocks]"],
  "metrics": {"complexity": 0, "lines_of_code": 0, "parameter_count": 0, "dependent_count": 0},
  "known_issues": ["[error description]"],
  "recommendations": ["Workaround: [what to do]", "Fix: [permanent solution]"]
}
EOF
bash ~/.kiro/scripts/commit_knowledge.sh --type issue --name "error_[description]" \
  --findings /tmp/error_findings.json --action create
```

**Check for known errors at task start:**
```bash
bash ~/.kiro/scripts/search_knowledge.sh --category issues --query "error"
bash ~/.kiro/scripts/search_knowledge.sh --category issues --query "genero_tools"
```

**Error naming convention:** `error_genero_tools_timeout`, `error_akr_lock_timeout`, `error_missing_brodir`

---

## Error Handling Strategy

**Always try genero-tools first.** Fall back to grep/sed/awk only when:
- genero-tools returns an error or empty result
- Output is malformed or incomplete
- Tool is unavailable

**Decision:**
```
genero-tools query
  → Success: use result, verify against source if incomplete (see workflow Rule 3a)
  → Failure: use grep fallback, log why genero-tools wasn't used
```

---

## Fallback Reference

When genero-tools is unavailable, use these grep equivalents:

```bash
# Find a function
grep -rn "FUNCTION my_function\|PRIVATE FUNCTION my_function" --include="*.4gl"

# Find what a function calls (read its body)
sed -n '/^FUNCTION my_function/,/^END FUNCTION/p' path/to/file.4gl | grep "CALL"

# Find what calls a function
grep -r "CALL my_function\|my_function(" --include="*.4gl" | grep -v "^.*FUNCTION my_function"

# List all functions in a file
grep -n "^FUNCTION\|^PRIVATE FUNCTION" path/to/file.4gl

# Find a code reference
grep -r "PRB-299" --include="*.4gl" -B 2 -A 2

# Search functions by pattern
grep -r "^FUNCTION get_\|^PRIVATE FUNCTION get_" --include="*.4gl" | sed 's/.*FUNCTION //' | awk '{print $1}' | sort -u
```

Always log fallback usage: `[TIMESTAMP] [FALLBACK] Using grep for find-function — reason: [why]`

---

## AKR Troubleshooting

**"AKR base path does not exist"**
```bash
bash ~/.kiro/scripts/setup_akr.sh
```

**"Permission denied" on AKR**
```bash
chmod 775 $GENERO_AKR_BASE_PATH && chmod 775 $GENERO_AKR_BASE_PATH/*
```

**"Failed to acquire lock after 30s"**
Stale locks are now auto-cleaned by `commit_knowledge.sh`. If it persists:
```bash
find $GENERO_AKR_BASE_PATH/.locks/ -type d -mmin +5 -exec rmdir {} \; 2>/dev/null
```

**"Knowledge already exists" on --action create**
Fixed — `commit_knowledge.sh` now auto-appends on collision. If you see this, update to the latest scripts.

**genero-tools not found**
```bash
echo $BRODIR                                    # must be set
ls -la $BRODIR/etc/genero-tools/query.sh        # must exist
export BRODIR=/path/to/genero                   # fix if missing
```

**INDEX.md not updating after commit**
```bash
bash ~/.kiro/scripts/update_metadata.sh --type function --name "artifact" --action append
tail -20 $GENERO_AKR_BASE_PATH/.logs/akr.log | grep ERROR
```
