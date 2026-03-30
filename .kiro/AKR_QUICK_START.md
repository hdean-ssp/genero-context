# AKR Quick Start Guide

**Get up and running with the Agent Knowledge Repository in 5 minutes.**

---

## Step 1: Initialize AKR (Admin Only)

Run this once to set up the shared AKR:

```bash
bash .kiro/setup_akr.sh
```

This creates the directory structure at `$BRODIR/etc/genero-akr` (or `/opt/genero/etc/genero-akr`).

---

## Step 2: Verify Setup

Check that everything is ready:

```bash
bash .kiro/validate_knowledge.sh
```

Expected output:
```
[INFO] Validating AKR at: /opt/genero/etc/genero-akr
[INFO] Validating Files...
  Total: 0, Valid: 0, Invalid: 0
...
[SUCCESS] All knowledge documents are valid!
```

---

## Step 3: Try Retrieval (Agent)

Try to retrieve knowledge (will be empty initially):

```bash
bash .kiro/retrieve_knowledge.sh --type function --name "test"
```

Expected output:
```
[ERROR] Knowledge not found: function/test
```

This is normal - no knowledge exists yet.

---

## Step 4: Create Sample Knowledge (Agent)

Create a sample findings file:

```bash
cat > /tmp/sample_findings.json << 'EOF'
{
  "summary": "Test function for AKR validation",
  "key_findings": [
    "This is a test function",
    "Used to validate AKR setup"
  ],
  "metrics": {
    "complexity": 5,
    "lines_of_code": 20,
    "parameter_count": 1,
    "dependent_count": 3
  },
  "dependencies": {
    "calls": "helper_function",
    "called_by": "main_function"
  },
  "type_information": {
    "parameters": "test_id (INTEGER)",
    "returns": "status (INTEGER)"
  },
  "patterns": {
    "naming": "verb_noun",
    "error_handling": "return status code"
  },
  "known_issues": [
    "No known issues"
  ],
  "recommendations": [
    "Add more comprehensive error handling"
  ],
  "related_knowledge": [
    "helper_function"
  ]
}
EOF
```

---

## Step 5: Commit Sample Knowledge

Commit the sample knowledge:

```bash
bash .kiro/commit_knowledge.sh \
  --type function \
  --name "test_function" \
  --findings /tmp/sample_findings.json \
  --action create
```

Expected output:
```
[INFO] Created new knowledge document: /opt/genero/etc/genero-akr/functions/test_function.md
[INFO] Knowledge committed successfully: function/test_function
```

---

## Step 6: Retrieve Sample Knowledge

Now retrieve the knowledge you just created:

```bash
bash .kiro/retrieve_knowledge.sh --type function --name "test_function"
```

Expected output:
```
# test_function

**Type:** function  
**Path:** src/test.4gl  
**Last Updated:** 2026-03-30T14:30:00Z  
**Updated By:** unknown  
**Status:** active

## Summary
Test function for AKR validation

## Key Findings
- This is a test function
- Used to validate AKR setup

...
```

---

## Step 7: Search Knowledge

Search for the knowledge you created:

```bash
bash .kiro/search_knowledge.sh --query "test"
```

Expected output:
```
Search Results for: test
======================================

[FUNCTION] test_function (2 matches)
  Summary: Test function for AKR validation
  File: /opt/genero/etc/genero-akr/functions/test_function.md
```

---

## Step 8: Append to Knowledge

Create updated findings:

```bash
cat > /tmp/updated_findings.json << 'EOF'
{
  "new_findings": [
    "Found 2 new dependents",
    "Complexity increased to 6"
  ]
}
EOF
```

Append to existing knowledge:

```bash
bash .kiro/commit_knowledge.sh \
  --type function \
  --name "test_function" \
  --findings /tmp/updated_findings.json \
  --action append
```

Expected output:
```
[INFO] Appended to knowledge document: /opt/genero/etc/genero-akr/functions/test_function.md
[INFO] Knowledge committed successfully: function/test_function
```

---

## Step 9: Verify Updated Knowledge

Retrieve the updated knowledge:

```bash
bash .kiro/retrieve_knowledge.sh --type function --name "test_function"
```

You should see the analysis history updated with the new entry.

---

## Step 10: Clean Up

Remove the test knowledge:

```bash
rm /opt/genero/etc/genero-akr/functions/test_function.md
rm /tmp/sample_findings.json /tmp/updated_findings.json
```

---

## Common Commands

### Retrieve Knowledge
```bash
# Function
bash .kiro/retrieve_knowledge.sh --type function --name "process_order"

# File
bash .kiro/retrieve_knowledge.sh --type file --path "src/orders.4gl"

# Module
bash .kiro/retrieve_knowledge.sh --type module --name "payment"

# Pattern
bash .kiro/retrieve_knowledge.sh --type pattern --name "error_handling"

# Issue
bash .kiro/retrieve_knowledge.sh --type issue --name "type_resolution_issues"
```

### Commit Knowledge
```bash
# Create new
bash .kiro/commit_knowledge.sh --type function --name "my_func" --findings findings.json --action create

# Append to existing
bash .kiro/commit_knowledge.sh --type function --name "my_func" --findings findings.json --action append

# Update (replace)
bash .kiro/commit_knowledge.sh --type function --name "my_func" --findings findings.json --action update

# Mark as deprecated
bash .kiro/commit_knowledge.sh --type function --name "my_func" --findings findings.json --action deprecate
```

### Search Knowledge
```bash
# Search all
bash .kiro/search_knowledge.sh --query "type resolution"

# Search functions only
bash .kiro/search_knowledge.sh --query "complexity" --type function

# Search patterns only
bash .kiro/search_knowledge.sh --query "error handling" --category patterns
```

### Validate Knowledge
```bash
bash .kiro/validate_knowledge.sh
```

---

## Configuration

### Change AKR Location

Edit `.kiro/akr-config.sh`:

```bash
# Change this line:
export GENERO_AKR_BASE_PATH="${BRODIR:-/opt/genero}/etc/genero-akr"

# To something like:
export GENERO_AKR_BASE_PATH="/shared/genero-akr"
```

Then run setup again:

```bash
bash .kiro/setup_akr.sh
```

---

## Environment Variables

Set these to customize behavior:

```bash
# Set agent ID for logging
export GENERO_AGENT_ID="agent-1"

# Set log level (debug, info, warning, error)
export GENERO_AKR_LOG_LEVEL="debug"

# Then run commands
bash .kiro/commit_knowledge.sh --type function --name "my_func" --findings findings.json --action create
```

---

## Next Steps

1. **Read the full guide:** `.kiro/AKR_SCRIPTS_README.md`
2. **Understand the workflow:** `.kiro/steering/genero-akr-workflow.md`
3. **Learn the concept:** `.kiro/steering/genero-agent-knowledge-repository.md`
4. **Integrate with your workflow:** Use scripts in Planner/Builder/Reviewer hats

---

## Troubleshooting

### "AKR base path does not exist"
```bash
bash .kiro/setup_akr.sh
```

### "Knowledge not found"
```bash
# Search for similar
bash .kiro/search_knowledge.sh --query "partial_name"

# Or create new
bash .kiro/commit_knowledge.sh --type function --name "new_func" --findings findings.json --action create
```

### "Permission denied"
```bash
# Check permissions
ls -la $GENERO_AKR_BASE_PATH

# Ask admin to fix if needed
chmod 775 $GENERO_AKR_BASE_PATH
chmod 775 $GENERO_AKR_BASE_PATH/*
```

### "Failed to acquire lock"
```bash
# Wait 30 seconds and try again
sleep 30
bash .kiro/commit_knowledge.sh ...
```

---

## Support

- Full documentation: `.kiro/AKR_SCRIPTS_README.md`
- Workflow guide: `.kiro/steering/genero-akr-workflow.md`
- Check logs: `$GENERO_AKR_BASE_PATH/.logs/akr.log`
- Validate: `bash .kiro/validate_knowledge.sh`

