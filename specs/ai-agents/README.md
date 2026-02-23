# AI Agents Specifications

This directory contains all AI agent-related configurations, prompts, and context.

## Directory Structure

```
ai-agents/
├── README.md              # This file
├── guidelines.md          # How AI agents should work with this project
├── prompts/               # Role-specific agent definitions
│   ├── _template.md       # Template for new agent roles
│   ├── backend-developer.md
│   ├── frontend-developer.md
│   ├── code-reviewer.md
│   └── feature-builder.md
└── context/               # Knowledge & context for agents
    ├── essential-knowledge.md    # MUST READ - Core project info
    ├── project-context.md        # High-level project overview
    ├── business-context.md       # Business logic & rules
    └── technical-context.md      # Tech stack & architecture
```

## Quick Start for AI Agents

1. Read `context/essential-knowledge.md` - **REQUIRED**
2. Read your role-specific prompt from `prompts/`
3. Follow `guidelines.md` for working with this project
4. Reference other context files as needed

## Agent Roles

- **Backend Developer** - Laravel API implementation
- **Frontend Developer** - Next.js/React implementation  
- **Code Reviewer** - Quality assurance & standards
- **Feature Builder** - End-to-end feature development

## Adding New Agent Roles

1. Copy `prompts/_template.md`
2. Customize for the new role
3. Update this README
