# AKR Scripts - Implementation Guide

**Status:** Phase 1 Implementation Complete  
**Version:** 1.0.0

---

## Overview

This directory contains the Phase 1 implementation of the Agent Knowledge Repository (AKR) system. These scripts enable agents to retrieve, commit, and search knowledge about Genero/4GL code artifacts.

---

## Configuration

### Path Configuration

All AKR paths are configured in a single file: **`akr-config.sh`**

**To change the AKR location:**

1. Edit `.kiro/akr-config.sh`
2. Change the `GENERO_AKR_BASE_PATH` variable:
   ```bash
   export GENERO_AKR_BASE_PATH="${BRODIR:-/opt/genero}/etc/genero-akr"
   ```
3. Run setup script to initialize new location:
   ```bash
   bash setup_akr.sh
   ```

**Current Configuration:**
- Base Path: `$BRODIR/etc/genero-akr` (or `/opt/genero/etc/genero-akr` if `$BRODIR` not set)
- Files: `$GENERO_AKR_BASE_PATH/files/`
- Functions: `$GENERO_AKR_BASE_PATH/functions/`
- Modules: `$GENERO_AKR_BASE_PATH/modules/`
- Patterns: `$GENERO_AKR_BASE_PATH/patterns/`
- Issues: `$GENERO_AKR_BASE_PATH/issues/`
- Metadata: `$GENERO_AKR_BASE_PATH/metadata/`

---

## Scripts

### 1. setup_akr.sh - Initialize AKR

**Purpose:** One-time setup to create AKR directory structure and initialize files.

**Usage:**
```bash
bash setup_akr.sh
```

**What it does:**
- Creates directory structure
- Initializes SCHEMA.md
- Initializes README.md
- Initializes INDEX.md
- Initializes metadata files
- Sets proper permissions for shared access

**When to run:**
- First time setting up AKR
- When changing AKR location
- When resetting AKR

**Example:**
```bash
# Initial setup
bash setup_akr.sh

# Output:
# [INFO] Setting up AKR at: /opt/genero/etc/genero-akr
# [INFO] Creating base directory: /opt/genero/etc/genero-akr
# [INFO] Creating directory: files
# ...
# [SUCCESS] AKR setup complete!
```

---

### 2. retrieve_knowledge.sh - Get Existing Knowledge

**Purpose:** Retrieve knowledge about an artifact from the AKR.

**Usage:**
```bash
bash retrieve_knowledge.sh --type TYPE --name NAME [--path PATH]
```

**Options:**
- `--type TYPE` - Type of artifact: function, file, module, pattern, issue
- `--name NAME` - Name of artifact (for function, module, pattern, issue)
- `--path PATH` - Path of artifact (for file type)

**Examples:**

```bash
# Retrieve function knowledge
bash retrieve_knowledge.sh --type function --name "process_order"

# Retrieve file knowledge
bash retrieve_knowledge.sh --type file --path "src/orders.4gl"

# Retrieve module knowledge
bash retrieve_knowledge.sh --type module --name "payment"

# Retrieve pattern knowledge
bash retrieve_knowledge.sh --type pattern --name "error_handling"

# Retrieve issue knowledge
bash retrieve_knowledge.sh --type issue --name "type_resolution_issues"
```

**Output:**
- Displays full knowledge document if found
- Returns error if knowledge not found

**Integration with Workflow:**
- Use in **Planner Hat** to retrieve existing knowledge before planning
- Use in **Builder Hat** to compare current findings with existing knowledge

---

### 3. commit_knowledge.sh - Save Knowledge

**Purpose:** Commit knowledge about an artifact to the AKR.

**Usage:**
```bash
bash commit_knowledge.sh --type TYPE --name NAME --findings FILE --action ACTION [--path PATH]
```

**Options:**
- `--type TYPE` - Type of artifact: function, file, module, pattern, issue
- `--name NAME` - Name of artifact (for function, module, pattern, issue)
- `--path PATH` - Path of artifact (for file type)
- `--findings FILE` - JSON file containing findings
- `--action ACTION` - Action: create, append, update, deprecate

**Actions:**
- `create` - Create new knowledge (first time analyzing artifact)
- `append` - Add findings to existing knowledge (preserve history)
- `update` - Replace existing knowledge (artifact significantly changed)
- `deprecate` - Mark knowledge as outdated (artifact no longer relevant)

**Findings JSON Format:**
```json
{
  "summary": "Brief description of artifact",
  "key_findings": [
    "Finding 1",
    "Finding 2"
  ],
  "metrics": {
    "complexity": 10,
    "lines_of_code": 55,
    "parameter_count": 1,
    "dependent_count": 15
  },
  "dependencies": {
    "calls": "validate_order, save_order",
    "called_by": "process_batch, handle_request"
  },
  "type_information": {
    "parameters": "order_id (INTEGER)",
    "returns": "status (INTEGER)"
  },
  "patterns": {
    "naming": "verb_noun",
    "error_handling": "return status code"
  },
  "known_issues": [
    "15 dependents make changes risky"
  ],
  "recommendations": [
    "Consider breaking into smaller functions"
  ],
  "related_knowledge": [
    "validate_order",
    "save_order"
  ],
  "new_findings": [
    "Discovered 3 new dependents"
  ]
}
```

**Examples:**

```bash
# Create new function knowledge
bash commit_knowledge.sh \
  --type function \
  --name "process_order" \
  --findings findings.json \
  --action create

# Append to existing function knowledge
bash commit_knowledge.sh \
  --type function \
  --name "process_order" \
  --findings findings.json \
  --action append

# Update function knowledge (artifact changed)
bash commit_knowledge.sh \
  --type function \
  --name "process_order" \
  --findings findings.json \
  --action update

# Mark function knowledge as deprecated
bash commit_knowledge.sh \
  --type function \
  --name "process_order" \
  --findings findings.json \
  --action deprecate
```

**Features:**
- File locking for concurrent access safety
- Automatic timestamp and agent ID recording
- Analysis history tracking
- Error handling and validation

**Integration with Workflow:**
- Use in **Reviewer Hat** to commit findings after analysis
- Automatically updates analysis history
- Logs all commits to activity log

---

### 4. search_knowledge.sh - Find Knowledge

**Purpose:** Search for knowledge in the AKR.

**Usage:**
```bash
bash search_knowledge.sh --query QUERY [--type TYPE] [--category CATEGORY]
```

**Options:**
- `--query QUERY` - Search query (required)
- `--type TYPE` - Limit search to type: function, file, module, pattern, issue
- `--category CAT` - Limit search to category: files, functions, modules, patterns, issues

**Examples:**

```bash
# Search all knowledge
bash search_knowledge.sh --query "type resolution"

# Search only functions
bash search_knowledge.sh --query "complexity" --type function

# Search only patterns
bash search_knowledge.sh --query "error handling" --category patterns

# Search for specific function
bash search_knowledge.sh --query "process_order"
```

**Output:**
- Lists matching artifacts with summaries
- Shows number of matches in each artifact
- Displays file paths for direct access

**Integration with Workflow:**
- Use in **Planner Hat** to find related knowledge
- Use to discover patterns and issues
- Use to find similar functions for pattern matching

---

### 5. validate_knowledge.sh - Check Consistency

**Purpose:** Validate schema compliance and consistency of knowledge documents.

**Usage:**
```bash
bash validate_knowledge.sh
```

**What it checks:**
- Required sections present
- Valid status values
- Valid timestamp format
- Valid artifact types
- File readability

**Examples:**

```bash
# Validate all knowledge
bash validate_knowledge.sh

# Output:
# [INFO] Validating AKR at: /opt/genero/etc/genero-akr
# [INFO] Validating Files...
#   Total: 5, Valid: 5, Invalid: 0
# [INFO] Validating Functions...
#   Total: 12, Valid: 12, Invalid: 0
# ...
# [SUCCESS] All knowledge documents are valid!
```

**Integration with Workflow:**
- Use in **Reviewer Hat** before committing knowledge
- Use in maintenance to ensure data integrity
- Use in CI/CD pipelines for quality checks

---

## Workflow Integration

### Planner Hat (Inception Phase)

**Step 1: Identify Target Artifacts**
```bash
TARGET_FUNCTION="process_order"
TARGET_FILE="src/orders.4gl"
```

**Step 2: Retrieve Existing Knowledge**
```bash
bash retrieve_knowledge.sh --type function --name "$TARGET_FUNCTION"
bash retrieve_knowledge.sh --type file --path "$TARGET_FILE"
```

**Step 3: Review and Compare**
- Read existing analysis
- Compare with current genero-tools data
- Identify what's new or changed

---

### Builder Hat (Construction Phase)

**Step 1: Perform Current Analysis**
```bash
bash query.sh find-function "$TARGET_FUNCTION"
bash query.sh find-function-dependents "$TARGET_FUNCTION"
```

**Step 2: Retrieve Existing Knowledge**
```bash
bash retrieve_knowledge.sh --type function --name "$TARGET_FUNCTION"
```

**Step 3: Identify New Insights**
- Compare current findings with existing knowledge
- Document new findings in JSON format
- Prepare for commit

---

### Reviewer Hat (Operation Phase)

**Step 1: Validate Findings**
```bash
bash validate_knowledge.sh
```

**Step 2: Decide Commit Action**
- First analysis? Use `--action create`
- Adding to existing? Use `--action append`
- Artifact changed? Use `--action update`
- No longer relevant? Use `--action deprecate`

**Step 3: Commit Knowledge**
```bash
bash commit_knowledge.sh \
  --type function \
  --name "$TARGET_FUNCTION" \
  --findings findings.json \
  --action append
```

---

## Environment Variables

### Configuration
- `GENERO_AKR_BASE_PATH` - Base path for AKR (set in akr-config.sh)
- `BRODIR` - Used to construct default AKR path

### Logging
- `GENERO_AKR_LOG_LEVEL` - Log level: debug, info, warning, error (default: info)
- `GENERO_AKR_LOG_FILE` - Log file path (default: $GENERO_AKR_BASE_PATH/.logs/akr.log)

### Agent Identification
- `GENERO_AGENT_ID` - Agent identifier for logging (default: "unknown")

**Example:**
```bash
export GENERO_AGENT_ID="agent-1"
export GENERO_AKR_LOG_LEVEL="debug"
bash commit_knowledge.sh --type function --name "process_order" --findings findings.json --action create
```

---

## Troubleshooting

### Issue: "AKR base path does not exist"

**Cause:** AKR not initialized

**Solution:**
```bash
bash setup_akr.sh
```

---

### Issue: "Knowledge not found"

**Cause:** Knowledge document doesn't exist

**Solution:**
1. Check artifact name spelling
2. Search for similar artifacts:
   ```bash
   bash search_knowledge.sh --query "partial_name"
   ```
3. Create new knowledge if first analysis:
   ```bash
   bash commit_knowledge.sh --type function --name "new_function" --findings findings.json --action create
   ```

---

### Issue: "Failed to acquire lock"

**Cause:** Another agent is writing to same artifact

**Solution:**
1. Wait 30 seconds (lock will be released)
2. Try again
3. If still fails, check for stuck locks:
   ```bash
   ls -la $GENERO_AKR_BASE_PATH/.locks/
   ```

---

### Issue: "Permission denied"

**Cause:** File permissions not set correctly for shared access

**Solution:**
```bash
# Check permissions
ls -la $GENERO_AKR_BASE_PATH

# Should be: drwxrwxr-x (775)
# If not, ask admin to fix:
chmod 775 $GENERO_AKR_BASE_PATH
chmod 775 $GENERO_AKR_BASE_PATH/*
```

---

## Next Steps

### Phase 2 (Future)
- Add conflict resolution for simultaneous writes
- Add automatic INDEX.md updates
- Add statistics collection
- Add knowledge comparison tool

### Phase 3 (Future)
- Add automatic pattern detection
- Add issue flagging
- Add recommendation generation
- Add full-text search with indexing

### Phase 4 (Future)
- Add workflow hooks for automatic retrieval/commit
- Add audit trail
- Add knowledge quality scoring

---

## Related Documentation

- `.kiro/steering/genero-akr-workflow.md` - Workflow guide for agents
- `.kiro/steering/genero-agent-knowledge-repository.md` - AKR concept and architecture
- `.kiro/steering/genero-framework-assessment.md` - Framework assessment and implementation plan
- `$GENERO_AKR_BASE_PATH/SCHEMA.md` - Knowledge document schema
- `$GENERO_AKR_BASE_PATH/README.md` - AKR overview

---

## Support

For issues or questions:
1. Check troubleshooting section above
2. Review workflow guide: `.kiro/steering/genero-akr-workflow.md`
3. Check logs: `$GENERO_AKR_BASE_PATH/.logs/akr.log`
4. Validate knowledge: `bash validate_knowledge.sh`

