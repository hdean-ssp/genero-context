# Kiro Skills Directory

**Purpose**: Specialized expertise skills for Kiro IDE

**Status**: Active

---

## Overview

Kiro skills are reusable, specialized capabilities that extend Kiro's functionality. They provide expert guidance for specific domains and can be activated on-demand.

### What Are Skills?

Skills are:
- **Specialized expertise** - Deep knowledge in a specific domain
- **Reusable** - Can be used across multiple projects
- **Activatable** - Loaded when needed to provide focused context
- **Documented** - Complete with examples and best practices
- **Practical** - Focused on real-world workflows

### How to Use Skills

1. **Activate a skill** in your workflow:
   ```
   I need expertise in AKR management. Please activate the 
   "AKR Management Specialist" skill.
   ```

2. **Use the skill** to guide your work:
   - Follow the frameworks and workflows
   - Apply the best practices
   - Use the checklists and templates
   - Reference the examples

3. **Integrate with your workflow**:
   - Use in Planner Hat for planning
   - Use in Builder Hat for implementation
   - Use in Reviewer Hat for validation

---

## Available Skills

### 1. AKR Management Specialist

**File**: `akr-management-specialist.md`

**Purpose**: Expert guidance for maintaining the Agent Knowledge Repository with focus on deduplication, structure integrity, and sentiment analysis

**Keywords**: AKR, knowledge-management, deduplication, structure, sentiment-analysis

**Includes**:
- Deduplication strategy and workflows
- Structure integrity validation
- Sentiment analysis and bias detection
- Quality scoring framework
- Best practices and troubleshooting

**When to Activate**:
- Creating new knowledge documents
- Reviewing existing knowledge
- Maintaining AKR quality
- Preventing duplicates
- Ensuring objective analysis

**Key Sections**:
1. **Part 1: Deduplication Strategy**
   - Identify potential duplicates
   - Analyze existing knowledge
   - Decide on action (create vs append)
   - Merge duplicates
   - Prevent future duplicates

2. **Part 2: Structure Integrity**
   - Standard document structure
   - Validation rules
   - Metadata validation
   - Metrics validation
   - Findings validation

3. **Part 3: Sentiment Analysis**
   - Objective vs subjective statements
   - Evidence-based claims
   - Neutral tone
   - Balanced perspective
   - Bias detection techniques

---

## Supporting Materials

### Training Guide

**File**: `akr-management-training.md`

**Purpose**: Hands-on training to master AKR management

**Includes**:
- 4 training modules
- 12+ practical exercises
- Real-world scenarios
- Solutions and explanations
- Self-assessment checklist

**Modules**:
1. **Module 1: Deduplication Mastery** (3 exercises)
2. **Module 2: Structure Integrity** (3 exercises)
3. **Module 3: Sentiment Analysis** (4 exercises)
4. **Module 4: Integrated Practice** (2 exercises)

**Duration**: 2-3 hours

**Difficulty**: Intermediate

### Quick Reference

**File**: `akr-management-quick-reference.md`

**Purpose**: Fast lookup guide for common AKR management tasks

**Includes**:
- Quick reference for each topic
- Common tasks with step-by-step instructions
- Decision trees
- Quality scoring guide
- Common issues and solutions
- Commands summary
- Best practices checklist

**Use When**:
- You need quick answers
- You're in the middle of a task
- You need to remember a command
- You need a checklist

---

## Skill Structure

Each skill includes:

### 1. Overview
- Purpose and keywords
- When to activate
- Key concepts

### 2. Core Content
- Detailed frameworks
- Workflows and processes
- Best practices
- Examples and scenarios

### 3. Integration
- How to use in Planner Hat
- How to use in Builder Hat
- How to use in Reviewer Hat

### 4. Reference
- Commands and tools
- Checklists
- Troubleshooting
- Related documentation

---

## How to Activate Skills

### Method 1: In Chat

```
I'm working on [task] and need expertise in [domain]. 
Please activate the "[Skill Name]" skill.
```

**Example**:
```
I'm creating new AKR knowledge documents and need expertise 
in deduplication and structure validation. Please activate 
the "AKR Management Specialist" skill.
```

### Method 2: Using discloseContext Tool

```
I need to activate the AKR Management Specialist skill 
to guide my work on knowledge repository maintenance.
```

### Method 3: Automatic Activation

Skills with `inclusion: auto` are automatically loaded when relevant keywords are detected.

---

## Skill Development

### Creating New Skills

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
   - Examples and scenarios

### Skill Template

```markdown
# [Skill Name]

**Purpose**: [What this skill enables]

**Keywords**: [comma-separated keywords]

**Inclusion**: manual | auto

**Version**: 1.0.0

**Status**: Production Ready | Beta | Development

---

## Overview

[Detailed explanation of skill purpose and scope]

---

## Core Content

[Main frameworks, workflows, and best practices]

---

## Integration

[How to use in different workflow phases]

---

## Reference

[Commands, checklists, troubleshooting]

---

## Related Documentation

[Links to related materials]
```

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

## Using Skills Effectively

### 1. Activate at Right Time

**Good**: Activate when starting a task that needs expertise
```
I'm about to create new AKR knowledge. Please activate 
the AKR Management Specialist skill.
```

**Not ideal**: Activate for every task
```
Please activate all skills.
```

### 2. Reference Specific Sections

**Good**: Reference specific frameworks
```
Using the deduplication workflow from the AKR Management 
Specialist skill, I'll search for existing knowledge first.
```

**Not ideal**: Generic reference
```
The skill says to do something.
```

### 3. Apply to Real Work

**Good**: Use skill to guide actual work
```
Following the sentiment analysis checklist from the skill, 
I'll review this finding for bias.
```

**Not ideal**: Just read the skill
```
I read the skill but didn't apply it.
```

### 4. Iterate and Improve

**Good**: Refine approach based on skill guidance
```
The skill recommends validating structure before commit. 
I found 3 issues and fixed them.
```

**Not ideal**: Ignore feedback
```
The skill says to validate, but I'll skip it.
```

---

## Integration with Steering

### Difference Between Skills and Steering

**Steering Files**:
- General guidance for all work
- Always included or conditionally included
- Broad scope (applies to many tasks)
- Examples: workflow rules, standards, conventions

**Skills**:
- Specialized expertise for specific domains
- Manually activated or auto-activated
- Narrow scope (applies to specific tasks)
- Examples: AKR management, code analysis, type resolution

### Using Together

Skills and steering work together:
- **Steering** provides general framework
- **Skills** provide specialized expertise
- **Steering** defines when to use skills
- **Skills** provide detailed guidance

---

## Support and Feedback

### Getting Help

1. **Review skill documentation**
   - Read the full skill file
   - Check the training guide
   - Use the quick reference

2. **Check examples**
   - Look for real-world scenarios
   - Review best practices
   - Study the exercises

3. **Use troubleshooting**
   - Check common issues
   - Review solutions
   - Verify your approach

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
   I need to work on AKR management. Please activate the 
   AKR Management Specialist skill.
   ```

2. **Choose your path**:
   - **Learning**: Start with `akr-management-training.md`
   - **Quick answers**: Use `akr-management-quick-reference.md`
   - **Deep dive**: Read `akr-management-specialist.md`

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
