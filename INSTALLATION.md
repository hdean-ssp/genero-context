# Installation Guide

## Requirements

- Linux/Unix system (RHEL 9 or compatible), Bash 4.0+
- Genero/4GL installed with `$BRODIR` environment variable set
- genero-tools at `$BRODIR/etc/genero-tools`
- Write access to a shared directory for the AKR (default: `$BRODIR/etc/genero-akr`)
- Standard Unix utilities: grep, sed, awk, find, mkdir, chmod
- Optional: `jq` for enhanced JSON handling (`sudo yum install jq`)

## Quick install

```bash
git clone https://github.com/hdean-ssp/genero-context.git
cd genero-context
bash install.sh
```

The installer will:
1. Pull the latest changes from the repo
2. Verify all framework files are present
3. Back up any existing `~/.kiro` files
4. Copy scripts, steering files, skills, and hooks to `~/.kiro/`

Flags:
- `--force` – skip confirmation prompts
- `--skip-genero-check` – skip genero-tools verification

## Initialize the AKR

Run once as admin to create the knowledge store:

```bash
bash ~/.kiro/scripts/setup_akr.sh
```

This creates the directory structure at `$BRODIR/etc/genero-akr` (configurable).

## Configuration

All paths are set in `~/.kiro/scripts/akr-config.sh`:

```bash
# Change this one line to move the AKR anywhere
export GENERO_AKR_BASE_PATH="${BRODIR:-/opt/genero}/etc/genero-akr"
```

Other useful environment variables:

```bash
export GENERO_AGENT_ID="agent-1"          # identifies this agent in logs
export GENERO_AKR_LOG_LEVEL="info"        # debug | info | warning | error
```

## Verify the installation

```bash
bash ~/.kiro/scripts/validate_knowledge.sh
```

Expected output: `[SUCCESS] All knowledge documents are valid!`

## Manual installation (alternative)

If you prefer not to use the installer:

```bash
mkdir -p ~/.kiro/{scripts,steering,skills,hooks}

cp .kiro/scripts/*.sh ~/.kiro/scripts/
chmod +x ~/.kiro/scripts/*.sh

cp .kiro/steering/*.md ~/.kiro/steering/
cp .kiro/skills/*.md   ~/.kiro/skills/
cp .kiro/hooks/*       ~/.kiro/hooks/
```

## genero-tools setup

The framework expects genero-tools at `$BRODIR/etc/genero-tools`. If it's missing:

```bash
# Check
ls -la $BRODIR/etc/genero-tools

# Install from your Genero distribution
sudo mkdir -p $BRODIR/etc/genero-tools
sudo tar -xzf genero-tools-*.tar.gz -C $BRODIR/etc/genero-tools
sudo chmod 755 $BRODIR/etc/genero-tools $BRODIR/etc/genero-tools/*

# Or point to a custom location in akr-config.sh
export GENERO_TOOLS_PATH="/custom/path/to/genero-tools"
```

See [.kiro/genero-tools-docs/GENERO_TOOLS_SETUP.md](.kiro/genero-tools-docs/GENERO_TOOLS_SETUP.md) for more detail.

## Troubleshooting

**"AKR base path does not exist"**
```bash
bash ~/.kiro/scripts/setup_akr.sh
```

**"Permission denied" on AKR directory**
```bash
chmod 775 $GENERO_AKR_BASE_PATH
chmod 775 $GENERO_AKR_BASE_PATH/*
```

**"Knowledge not found"** – normal if AKR is empty. Create your first entry:
```bash
echo '{"summary":"test","key_findings":["test"],"metrics":{"complexity":1}}' > /tmp/f.json
bash ~/.kiro/scripts/commit_knowledge.sh --type function --name "test" --findings /tmp/f.json --action create
```

**"Failed to acquire lock"** – another process holds the lock. Wait 30s and retry.

**"BRODIR not set"**
```bash
export BRODIR=/opt/genero   # or your Genero install path
```
