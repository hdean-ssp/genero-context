# Kiro Skills Index

**Purpose**: Master index of all Kiro skills and their documentation

**Last Updated**: 2026-03-30

---

## Available Skills

### 1. AKR Management Specialist

**Status**: Production Ready ✅  
**Version**: 1.0.0  
**Keywords**: AKR, knowledge-management, deduplication, structure, sentiment-analysis

**Purpose**: Expert guidance for maintaining the Agent Knowledge Repository with focus on deduplication, structure integrity, and sentiment analysis

**Files**:
- **Core Skill**: `akr-management-specialist.md` (~3,500 lines)
- **Training**: `akr-management-training.md` (~2,000 lines)
- **Quick Reference**: `akr-management-quick-reference.md` (~1,000 lines)
- **Activation Guide**: `ACTIVATION_GUIDE.md` (~400 lines)

**When to Activate**:
- Creating new AKR knowledge documents
- Reviewing existing AKR knowledge
- Maintaining AKR quality
- Preventing duplicate entries
- Ensuring objective analysis

**Key Topics**:
1. **Deduplication** - Preventing and eliminating duplicate knowledge entries
2. **Structure Integrity** - Maintaining consistent, valid document structure
3. **Sentiment Analysis** - Ensuring accurate, unbiased analysis

**Learning Path**:
- Quick Start: 30 minutes (activation guide + quick reference)
- Standard Training: 2-3 hours (training guide + exercises)
- Deep Dive: 4-5 hours (core skill + training + exercises)

**Quality Framework**:
- Structure (30%) + Content (40%) + Sentiment (20%) + Deduplication (10%) = Quality Score
- Target: > 85/100

---

## Planned Skills

### Genero Code Analysis Specialist

**Status**: Planned  
**Keywords**: genero, code-analysis, complexity, dependencies

**Purpose**: Deep expertise in analyzing Genero/4GL code using genero-tools

**Topics**:
- Interpreting genero-tools query results
- Common patterns in Genero code
- Type resolution troubleshooting
- Complexity assessment guidelines
- Dependency analysis best practices

---

### Genero Script Development

**Status**: Planned  
**Keywords**: genero, scripts, bash, development

**Purpose**: Expertise in creating and debugging Genero tools scripts

**Topics**:
- Script structure and patterns
- Error handling in bash scripts
- Configuration management
- Logging and debugging techniques
- Testing strategies for scripts

---

### Genero Workflow Orchestration

**Status**: Planned  
**Keywords**: genero, workflow, orchestration, planning

**Purpose**: Understanding the AI-DLC workflow adapted for Genero

**Topics**:
- How Planner/Builder/Reviewer hats apply to Genero work
- Integration points with genero-tools
- AKR workflow integration
- Approval gate patterns
- Risk assessment for Genero changes

---

### Genero Type Resolution Expert

**Status**: Planned  
**Keywords**: genero, types, LIKE, resolution

**Purpose**: Specialized knowledge about LIKE types and type resolution

**Topics**:
- LIKE type syntax and resolution
- Common type resolution issues
- Debugging unresolved types
- Type validation strategies
- Database schema understanding

---

## How to Use This Index

### Find a Skill

1. **By Name**: Look for skill name in "Available Skills" section
2. **By Keywords**: Search for relevant keywords
3. **By Purpose**: Find skill that matches your need

### Activate a Skill

```
I need expertise in [skill purpose]. Please activate the 
"[Skill Name]" skill.
```

**Example**:
```
I'm working on AKR management and need expertise in 
deduplication, structure integrity, and sentiment analysis. 
Please activate the "AKR Management Specialist" skill.
```

### Learn a Skill

1. **Quick Start** (30 min): Read activation guide + quick reference
2. **Standard Training** (2-3 hours): Complete training guide + exercises
3. **Deep Dive** (4-5 hours): Read core skill + training + exercises

### Use a Skill

1. **In Planner Hat**: Use for planning and understanding
2. **In Builder Hat**: Use for implementation and verification
3. **In Reviewer Hat**: Use for validation and quality assurance

---

## Skill Structure

Each skill includes:

### 1. Core Skill Document
- Complete expertise documentation
- Frameworks and workflows
- Best practices and patterns
- Integration with workflow phases
- Reference materials

### 2. Training Guide (Optional)
- Learning modules
- Practical exercises
- Real-world scenarios
- Solutions and explanations
- Self-assessment checklist

### 3. Quick Reference (Optional)
- Fast lookup for common tasks
- Decision trees
- Commands and tools
- Checklists
- Common issues and solutions

### 4. Activation Guide (Optional)
- When to activate
- How to activate
- What you get
- Quick start workflow
- Learning path

---

## File Organization

```
.kiro/
├── skills/
│   ├── INDEX.md                                 # This file
│   ├── README.md                                # Skills overview
│   ├── akr-management-specialist.md             # Core skill
│   ├── akr-management-training.md               # Training guide
│   ├── akr-management-quick-reference.md        # Quick reference
│   └── ACTIVATION_GUIDE.md                      # Activation guide
├── SKILL_TRAINING_SUMMARY.md                    # Training summary
└── SKILL_CREATION_COMPLETE.md                   # Creation summary
```

---

## Quick Links

### AKR Management Specialist

**Start Here**: `.kiro/skills/ACTIVATION_GUIDE.md`

**Learn**: `.kiro/skills/akr-management-training.md`

**Reference**: `.kiro/skills/akr-management-quick-reference.md`

**Deep Dive**: `.kiro/skills/akr-management-specialist.md`

### Related Documentation

**AKR Scripts**: `.kiro/AKR_SCRIPTS_README.md`

**AKR Workflow**: `.kiro/steering/genero-akr-workflow.md`

**AKR Schema**: `$GENERO_AKR_BASE_PATH/SCHEMA.md`

**Skills Overview**: `.kiro/skills/README.md`

---

## Skill Lifecycle

### Development Phases

1. **Development** - Initial creation and testing
2. **Beta** - Limited use, gathering feedback
3. **Production Ready** - Fully tested and documented
4. **Maintenance** - Regular updates and improvements
5. **Deprecated** - No longer recommended, replaced by newer skill

### Version Management

Skills use semantic versioning:
- **Major** (1.0.0) - Breaking changes
- **Minor** (1.1.0) - New features
- **Patch** (1.0.1) - Bug fixes

---

## Creating New Skills

To create a new skill:

1. **Create skill file**: `.kiro/skills/[skill-name].md`
2. **Include metadata**:
   - Purpose
   - Keywords
   - Inclusion type (manual or auto)
   - Version and status

3. **Structure content**:
   - Overview
   - Core frameworks
   - Workflows
   - Best practices
   - Integration points
   - Reference materials

4. **Add supporting materials**:
   - Training guide (optional)
   - Quick reference (optional)
   - Activation guide (optional)
   - Examples and scenarios

5. **Update this index**:
   - Add skill to "Available Skills" or "Planned Skills"
   - Include all metadata
   - Add quick links

---

## Best Practices for Skills

### 1. Focus on Expertise
- Provide deep, specialized knowledge
- Go beyond general guidance
- Include frameworks and workflows
- Provide practical examples

### 2. Make It Actionable
- Include step-by-step workflows
- Provide checklists
- Include commands and tools
- Show real examples

### 3. Integrate with Workflow
- Show how to use in Planner Hat
- Show how to use in Builder Hat
- Show how to use in Reviewer Hat
- Provide integration points

### 4. Support Learning
- Include training materials
- Provide exercises
- Show common mistakes
- Explain reasoning

### 5. Maintain Quality
- Keep content current
- Update with new learnings
- Fix errors and issues
- Improve based on feedback

---

## Skill Inventory

### Current Skills

| Skill | Status | Version | Keywords |
|-------|--------|---------|----------|
| AKR Management Specialist | Production Ready | 1.0.0 | AKR, knowledge-management, deduplication, structure, sentiment-analysis |

### Planned Skills

| Skill | Status | Keywords |
|-------|--------|----------|
| Genero Code Analysis Specialist | Planned | genero, code-analysis, complexity, dependencies |
| Genero Script Development | Planned | genero, scripts, bash, development |
| Genero Workflow Orchestration | Planned | genero, workflow, orchestration, planning |
| Genero Type Resolution Expert | Planned | genero, types, LIKE, resolution |

---

## Support

### Getting Help

1. **Quick Answers**: Use quick reference guide
2. **Learning**: Use training guide
3. **Deep Dive**: Read core skill document
4. **Overview**: Read skills directory README

### Providing Feedback

To improve skills:
1. Note what worked well
2. Identify what could be better
3. Suggest improvements
4. Share your experience

---

## Related Documentation

- `.kiro/steering/` - Steering files and general guidance
- `.kiro/AKR_SCRIPTS_README.md` - AKR scripts reference
- `.kiro/steering/genero-akr-workflow.md` - AKR workflow guide
- `.kiro/steering/genero-context-workflow.md` - AI-DLC workflow

---

## Quick Start

### To Use AKR Management Specialist Skill

1. **Activate the skill**:
   ```
   I'm working on AKR management. Please activate the 
   AKR Management Specialist skill.
   ```

2. **Choose your path**:
   - **Quick Start**: 30 minutes (activation guide + quick reference)
   - **Standard Training**: 2-3 hours (training guide + exercises)
   - **Deep Dive**: 4-5 hours (core skill + training + exercises)

3. **Apply to your work**:
   - Follow the workflows
   - Use the checklists
   - Reference the examples
   - Apply best practices

4. **Iterate and improve**:
   - Validate your work
   - Check quality scores
   - Refine your approach
   - Share learnings

---

**Last Updated**: 2026-03-30  
**Version**: 1.0.0  
**Status**: Active
