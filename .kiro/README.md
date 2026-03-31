# .kiro — Framework Files

This directory contains all framework files. Users interact via the scripts; everything else here is reference material.

## `/scripts` — 18 production scripts

```
setup_akr.sh          Initialize AKR directory structure
retrieve_knowledge.sh Retrieve stored knowledge
commit_knowledge.sh   Store new knowledge
search_knowledge.sh   Search knowledge repository
validate_knowledge.sh Validate knowledge structure
update_metadata.sh    Update metadata files
merge_knowledge.sh    Merge conflicting knowledge
compare_knowledge.sh  Compare knowledge versions
get_statistics.sh     Generate statistics
build_index.sh        Build search index
search_indexed.sh     Search indexed knowledge
detect_patterns.sh    Detect patterns in knowledge
flag_issues.sh        Flag potential issues
auto_retrieve.sh      Automatic knowledge retrieval
auto_commit.sh        Automatic knowledge commit
audit_trail.sh        Track audit trail
quality_score.sh      Calculate quality scores
akr-config.sh         Configuration (edit this to change paths)
```

See [scripts/README.md](scripts/README.md) for full usage reference.

## `/steering` — Workflow guides

Loaded automatically by Kiro IDE to guide agent behavior:

- `genero-context-workflow.md` — AI-DLC workflow (Inception/Construction/Operation)
- `genero-akr-workflow.md` — How agents use the AKR
- `genero-context-queries.md` — genero-tools query reference
- `genero-context-operations.md` — Error handling and fallback strategies

## `/skills` — AKR Management Specialist

Expert guidance for maintaining AKR quality (deduplication, structure, sentiment analysis).
See [skills/README.md](skills/README.md).

## `/hooks` — IDE hooks

Three hooks that automatically activate the AKR Management Specialist:
- Pre-retrieval deduplication check
- Pre-commit skill activation
- Post-commit quality validation

See [hooks/AKR_MANAGEMENT_HOOKS.md](hooks/AKR_MANAGEMENT_HOOKS.md).

## `/tests` — Test suite

51 tests covering Phase 1 and Phase 2 scripts.

```bash
bash .kiro/tests/run-all-tests.sh
```

See [tests/TEST_GUIDE.md](tests/TEST_GUIDE.md).

## `/genero-tools-docs` — genero-tools reference

Query reference, setup guide, architecture, and type resolution documentation.

## `/archive` — Archived documentation

Historical design and analysis documents kept for reference.
