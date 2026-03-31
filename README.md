# Genero Context Framework

A shared knowledge and workflow system for AI agents working with Genero/4GL codebases.

## What it does

- Gives AI agents a consistent workflow (Inception → Construction → Operation)
- Provides a shared **Agent Knowledge Repository (AKR)** so agents build on each other's analysis
- Integrates with **genero-tools** for semantic code queries
- Includes Kiro skills and hooks for automatic quality assurance

## Requirements

- Linux/Unix (RHEL 9 or compatible), Bash 4.0+
- Genero/4GL with `$BRODIR` set
- genero-tools at `$BRODIR/etc/genero-tools`
- Standard Unix utilities (grep, sed, awk, find)
- Optional: `jq` for enhanced JSON handling

## Installation

```bash
git clone https://github.com/hdean-ssp/genero-context.git
cd genero-context
bash install.sh
```

Then initialize the AKR (admin only):

```bash
bash ~/.kiro/scripts/setup_akr.sh
```

See [INSTALLATION.md](INSTALLATION.md) for full setup details.

## Basic usage

```bash
# Retrieve existing knowledge about a function
bash ~/.kiro/scripts/retrieve_knowledge.sh --type function --name "process_order"

# Commit new findings
bash ~/.kiro/scripts/commit_knowledge.sh \
  --type function --name "process_order" \
  --findings findings.json --action create

# Search knowledge
bash ~/.kiro/scripts/search_knowledge.sh --query "type resolution"

# Validate knowledge store
bash ~/.kiro/scripts/validate_knowledge.sh
```

## Documentation

| Doc | Purpose |
|-----|---------|
| [INSTALLATION.md](INSTALLATION.md) | Full setup and configuration guide |
| [FRAMEWORK.md](FRAMEWORK.md) | Architecture diagram and agent flow |
| [.kiro/scripts/README.md](.kiro/scripts/README.md) | All 18 scripts with usage examples |
| [.kiro/steering/](./kiro/steering/) | Workflow guides loaded automatically by Kiro |
| [.kiro/skills/](./kiro/skills/) | AKR Management Specialist skill |
| [.kiro/genero-tools-docs/](.kiro/genero-tools-docs/) | genero-tools query reference |

## Scripts overview

18 scripts organized in 4 phases:

- **Phase 1** – Core: setup, retrieve, commit, search, validate
- **Phase 2** – Metadata: update, merge, compare, statistics
- **Phase 3** – Analysis: build index, search indexed, detect patterns, flag issues
- **Phase 4** – Automation: auto retrieve/commit, audit trail, quality scoring

See [.kiro/scripts/README.md](.kiro/scripts/README.md) for the full reference.

## License

See [LICENSE](LICENSE).
