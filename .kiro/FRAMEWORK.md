# Framework Overview

How the Genero Context Framework works, how its parts interact, and the flow an agent follows on every task.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        KIRO IDE / AGENT                         │
│                                                                 │
│  ┌─────────────────┐    ┌──────────────────────────────────┐   │
│  │   Kiro Hooks    │    │         Steering Files           │   │
│  │  (auto-trigger) │    │       (always loaded)            │   │
│  │                 │    │                                  │   │
│  │ • boundary-     │    │ • genero-context-workflow.md     │   │
│  │   check         │    │   (rules, phases, AKR usage)     │   │
│  │ • akr-pre-      │    │ • genero-akr-workflow.md         │   │
│  │   commit        │    │   (document format, scripts)     │   │
│  │ • akr-post-     │    │ • genero-context-queries.md      │   │
│  │   commit        │    │   (query reference)              │   │
│  └────────┬────────┘    │ • genero-context-operations.md   │   │
│           │             │   (errors, fallbacks)            │   │
│           │             └──────────────────────────────────┘   │
│           │                                                     │
└───────────┼─────────────────────────────────────────────────────┘
            │
            ▼
┌───────────────────────────────────────────────────────────────────────┐
│                         AGENT TASK EXECUTION                          │
│                                                                       │
│   ┌─────────────────────────────────────────────────────────────┐    │
│   │  INCEPTION PHASE  🎩 Planner Hat                            │    │
│   │                                                             │    │
│   │  1. Check AKR ──────────────────────────────────────────┐  │    │
│   │     retrieve_knowledge.sh (existing findings?)          │  │    │
│   │     search_knowledge.sh (known issues?)                 │  │    │
│   │                                                         │  │    │
│   │  2. Query genero-tools ──────────────────────────────┐  │  │    │
│   │     find-function, find-function-dependents,         │  │  │    │
│   │     find-function-dependencies, find-function-       │  │  │    │
│   │     resolved, search-functions                       │  │  │    │
│   │                                                      │  │  │    │
│   │  3. Verify output ───────────────────────────────────┘  │  │    │
│   │     Incomplete result? → grep source to investigate     │  │    │
│   │     Tool gap? → note it, don't report as code defect    │  │    │
│   │                                                         │  │    │
│   │  4. Document plan + audit log                           │  │    │
│   │                                                         │  │    │
│   │  ══════════ GATE 1: HUMAN APPROVES PLAN ══════════════  │  │    │
│   └─────────────────────────────────────────────────────────┘  │    │
│                              │                                  │    │
│                              ▼                                  │    │
│   ┌─────────────────────────────────────────────────────────┐  │    │
│   │  CONSTRUCTION PHASE  🔨 Builder Hat                     │  │    │
│   │                                                         │  │    │
│   │  1. Execute approved plan                               │  │    │
│   │  2. Query genero-tools for context during changes       │  │    │
│   │  3. Use grep fallback if genero-tools unavailable       │  │    │
│   │  4. Log every action to audit trail                     │  │    │
│   │                                                         │  │    │
│   │  ══════════ GATE 2: HUMAN REVIEWS WORK ═══════════════  │  │    │
│   └─────────────────────────────────────────────────────────┘  │    │
│                              │                                  │    │
│                              ▼                                  │    │
│   ┌─────────────────────────────────────────────────────────┐  │    │
│   │  OPERATION PHASE  ✓ Reviewer Hat                        │  │    │
│   │                                                         │  │    │
│   │  1. Validate quality, check dependents                  │  │    │
│   │  2. Commit findings to AKR ─────────────────────────┐  │  │    │
│   │     commit_knowledge.sh (functions, modules, files)  │  │  │    │
│   │     commit_knowledge.sh --type issue (gaps/errors)   │  │  │    │
│   │                                                      │  │  │    │
│   │  ══════════ GATE 3: HUMAN APPROVES COMPLETION ══════  │  │    │
│   └─────────────────────────────────────────────────────────┘  │    │
│                                                                 │    │
└─────────────────────────────────────────────────────────────────────┘
            │                              │
            ▼                              ▼
┌───────────────────────┐    ┌─────────────────────────────────────┐
│     genero-tools      │    │   Agent Knowledge Repository (AKR)  │
│  $BRODIR/etc/         │    │   $BRODIR/etc/genero-akr/           │
│  genero-tools/        │    │                                     │
│                       │    │   functions/   ← per-function docs  │
│  query.sh             │    │   modules/     ← per-module docs    │
│  find-function        │    │   files/       ← per-file docs      │
│  find-dependents      │    │   patterns/    ← discovered patterns│
│  find-dependencies    │    │   issues/      ← errors & tool gaps │
│  find-resolved        │    │   metadata/    ← index, statistics  │
│  search-functions     │    │                                     │
│  list-file-functions  │    │   Managed by ~/.kiro/scripts/       │
│  find-reference       │    │   retrieve_knowledge.sh             │
│  unresolved-types     │    │   commit_knowledge.sh               │
│                       │    │   search_knowledge.sh               │
│  Source: .4gl files   │    │   validate_knowledge.sh             │
│  (never .42f/.42m)    │    │   compare_knowledge.sh              │
└───────────────────────┘    │   get_statistics.sh                 │
                             └─────────────────────────────────────┘
```

---

## Agent Task Flow (step by step)

```
Receive task
     │
     ▼
┌─────────────────────────────────────────────────┐
│ 1. AKR CHECK (mandatory before anything else)   │
│                                                 │
│    retrieve_knowledge.sh for each artifact      │
│    search_knowledge.sh for known issues         │
│                                                 │
│    Found? → use as baseline, skip re-analysis   │
│    Empty? → proceed to genero-tools             │
│    Stale? → re-analyze, update with --action    │
│             update                              │
└──────────────────────┬──────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│ 2. GENERO-TOOLS QUERIES                         │
│                                                 │
│    find-function → signature, complexity, LOC   │
│    find-function-dependents → impact scope      │
│    find-function-dependencies → what it calls   │
│    find-function-resolved → type resolution     │
│                                                 │
│    Result complete? → use it                    │
│    Result incomplete/unknown?                   │
│      → read source .4gl to investigate          │
│      → tool gap: log to AKR, don't flag as bug  │
│      → genuine issue: document as finding       │
└──────────────────────┬──────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│ 3. PLAN (Planner Hat)                           │
│                                                 │
│    Document: what AKR contained                 │
│              what genero-tools returned         │
│              what gaps were found               │
│              approach with clear steps          │
│              risks and dependencies             │
│                                                 │
│    ▶ Present to human → wait for approval       │
└──────────────────────┬──────────────────────────┘
                       │ approved
                       ▼
┌─────────────────────────────────────────────────┐
│ 4. IMPLEMENT (Builder Hat)                      │
│                                                 │
│    Execute plan step by step                    │
│    Query genero-tools for context as needed     │
│    Fallback to grep if tool unavailable         │
│    Log every action: [TIMESTAMP] [PHASE] ...    │
│                                                 │
│    ▶ Present work to human → wait for review    │
└──────────────────────┬──────────────────────────┘
                       │ reviewed
                       ▼
┌─────────────────────────────────────────────────┐
│ 5. VALIDATE + COMMIT (Reviewer Hat)             │
│                                                 │
│    Verify dependents still work                 │
│    Check for regressions                        │
│                                                 │
│    Commit to AKR:                               │
│      commit_knowledge.sh --type function ...    │
│      commit_knowledge.sh --type issue ...       │
│        (for any tool gaps or errors found)      │
│                                                 │
│    ▶ Present to human → wait for approval       │
└──────────────────────┬──────────────────────────┘
                       │ approved
                       ▼
                  Task complete ✓
                  (next agent starts at step 1
                   with richer AKR context)
```

---

## How the Parts Interact

| Component | Role | Loaded by |
|-----------|------|-----------|
| Steering files | Rules and workflow guidance loaded into every agent session | Kiro IDE (auto) |
| Kiro hooks | Intercept shell commands to enforce boundaries and AKR quality | Kiro IDE (auto) |
| genero-tools | Semantic code analysis — functions, dependencies, types | Agent (on demand) |
| AKR scripts | Read/write shared knowledge store | Agent (on demand) |
| AKR store | Persistent knowledge across agents and sessions | Filesystem |
| Source .4gl files | Ground truth — always verify tool output against these | Agent (on demand) |

---

## What the Hooks Do

| Hook | Triggers on | Purpose |
|------|-------------|---------|
| `codebase-boundary-check` | Every shell command | Flags destructive writes outside codebase; safe reads always proceed |
| `akr-management-auto-activate` | Shell commands containing `commit_knowledge.sh` | Reminds agent to check for duplicates before committing |
| `akr-management-post-commit-validate` | After shell commands containing `commit_knowledge.sh` | Runs `validate_knowledge.sh` to catch malformed documents |

---

## Key Rules at a Glance

1. **AKR first** — check existing knowledge before querying genero-tools
2. **genero-tools before grep** — always try the semantic tool first
3. **Verify incomplete output** — read source when genero-tools returns unknowns
4. **Tool gap ≠ code defect** — unresolved LIKE references are often a schema indexing issue
5. **Log everything** — every query, every decision, every gate response
6. **Commit findings** — every task ends with AKR updated, including gaps and errors
7. **Three gates** — human approves plan, reviews work, approves completion

---

## File Locations

```
Repository root
├── README.md              ← project overview + quick start
├── INSTALLATION.md        ← setup guide
├── FRAMEWORK.md           ← this file
├── install.sh             ← copies framework to ~/.kiro/
└── .kiro/
    ├── scripts/           ← 18 AKR management scripts
    ├── steering/          ← workflow rules (auto-loaded by Kiro)
    ├── hooks/             ← automatic quality checks
    ├── skills/            ← AKR Management Specialist skill
    └── genero-tools-docs/ ← genero-tools query reference

Runtime (created by setup_akr.sh)
└── $BRODIR/etc/genero-akr/
    ├── functions/         ← per-function knowledge
    ├── modules/           ← per-module knowledge
    ├── files/             ← per-file knowledge
    ├── patterns/          ← discovered patterns
    ├── issues/            ← errors and tool gaps
    └── metadata/          ← index and statistics
```
