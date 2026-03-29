# Genero Context Framework

A focused steering framework for Kiro that ensures all agents follow the same AI-DLC workflow pattern and use genero-tools consistently for codebase context gathering.

## Installation

Copy the three steering files to your Kiro workspace:

```bash
cp .kiro/steering/genero-context-workflow.md ~/.kiro/steering/
cp .kiro/steering/genero-context-queries.md ~/.kiro/steering/
cp .kiro/steering/genero-context-operations.md ~/.kiro/steering/
```

Restart Kiro. The framework will automatically load.

## What Agents Get

Once installed, agents will automatically have access to:

**1. Workflow & Agent Behavior** (`genero-context-workflow.md`)
- AI-DLC workflow pattern (Inception → Construction → Operation)
- Hat-based roles (Planner, Builder, Reviewer)
- Explicit agent behavior rules and approval gates
- Task type decision trees
- Consistency enforcement checkpoints
- Logging requirements

**2. Query Reference** (`genero-context-queries.md`)
- Quick reference for 6 essential queries
- Complete query reference with output formats
- Query selection decision matrix
- Common query patterns
- Performance expectations
- Tips & tricks

**3. Operations & Troubleshooting** (`genero-context-operations.md`)
- Error handling and fallback strategies
- Fallback query reference (grep, sed, awk)
- Common errors and solutions
- Configuration guidance
- Troubleshooting guide
- Logging best practices
- Performance tuning

## Why Three Files?

The framework is split into three focused files to:
- **Reduce cognitive load**: Agents focus on one concern at a time
- **Improve adoption**: Shorter files are more likely to be read
- **Enable maintenance**: Updates to queries don't affect workflow guidance
- **Support scalability**: Easy to add new use cases or queries

## Files

- `.kiro/steering/genero-context-workflow.md` - **Workflow & agent behavior** (copy to workspace)
- `.kiro/steering/genero-context-queries.md` - **Query reference** (copy to workspace)
- `.kiro/steering/genero-context-operations.md` - **Operations & troubleshooting** (copy to workspace)
- `genero-tools-docs/` - Reference documentation (optional, for agents to refer to)
- `LICENSE` - License information

## Quick Start for Agents

1. **Receive a task** → Start with Planner Hat (see `genero-context-workflow.md`)
2. **Gather context** → Use queries from `genero-context-queries.md`
3. **Handle errors** → Follow guidance in `genero-context-operations.md`
4. **Follow workflow** → Always: Planner → Builder → Reviewer
5. **Get approval** → Wait for human approval at each gate

## Key Principles

- **AI-DLC Workflow**: Every task follows Inception → Construction → Operation
- **Hat-Based Roles**: Planner (plan), Builder (execute), Reviewer (validate)
- **genero-tools First**: Always try genero-tools before fallback tools
- **Mandatory Approval Gates**: Human approval required between phases
- **Consistent Logging**: All decisions and queries logged with timestamps
- **Graceful Degradation**: Fallback to grep/sed/awk if genero-tools unavailable

## License

See LICENSE file for details.
