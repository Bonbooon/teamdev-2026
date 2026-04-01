# GitHub Copilot Instructions for Motivation Cloud Teamwork Project

Welcome! This directory contains context and guidelines for GitHub Copilot to assist with development on this hackathon project.

---

## How Copilot Should Behave in This Repo

### Core Principles

1. **Spec-First Development**: Always ask or remind the user to check specs before implementing
2. **Product Awareness**: Keep project goals in mind - we're building for project managers to prevent delays
3. **Documentation Sync**: Remind users to update docs when learning new information
4. **Dogfooding Mindset**: Suggest features that would help our own team first
5. **Quality Standards**: Enforce TypeScript strict mode, no `any`, proper testing

### Copilot's Role

- **Clarify** project context when implementing features
- **Reference** specs and docs when suggesting code
- **Validate** that features align with the 4 core pillars
- **Remind** about testing, model-code sync, and documentation updates
- **Guide** users through workflows (spec-first, code generation, git conventions)

### Frontend Command Execution Policy

- Run frontend `pnpm` commands from the active workspace/worktree's `teamdev-2026-front/` directory in the host shell.
- Prefer `./scripts/quality-gates.sh` from the active workspace/worktree root for full validation.
- Never run frontend quality-gate `pnpm` commands inside the frontend container (`docker compose exec front ...`, `docker exec ...front ...`).
- Never run `pnpm install`, `pnpm add`, `npm install`, or global package installs merely to make quality gates run.
- If frontend dependencies are unavailable in the worktree, stop and report the blocker instead of mutating the environment unless the user explicitly requested dependency/setup work.

---

## Quick Navigation to Skills

| Skill                                                                | When to Reference                 | Key Topics                                                             |
| -------------------------------------------------------------------- | --------------------------------- | ---------------------------------------------------------------------- |
| [product-context](skills/product-context/SKILL.md)                   | Understanding what we're building | 4 pillars, dogfooding, Phase 1 vs Phase 2                              |
| [architecture](skills/architecture/SKILL.md)                         | System design questions           | Tech stack, API flow, directories, model sync                          |
| [code-style](skills/code-style/SKILL.md)                             | Writing code                      | Conventions, patterns, quality standards                               |
| [workflow](skills/workflow/SKILL.md)                                 | Process questions                 | Spec-first, git conventions, code generation                           |
| [git-commit-quality-gates](skills/git-commit-quality-gates/SKILL.md) | Preparing commits / CI hygiene    | Logical commit grouping, conventional commits, mise+pnpm quality gates |
| [testing](skills/testing/SKILL.md)                                   | Writing tests                     | Test strategy, mocking policy, coverage                                |
| [quick-start-guide](skills/quick-start-guide/SKILL.md)               | Common tasks                      | Adding endpoints, components, migrations                               |

---

## Feature Specifications (For Implementation)

| Spec                                                    | When to Reference                       |
| ------------------------------------------------------- | --------------------------------------- |
| [alert-system.md](../../specs/business/alert-system.md) | Implementing alert triggers and actions |

---

## Essential Context Files (For Full Details)

- **Product Brief**: `specs/business/product-brief.md` - Complete requirements and business context
- **Prototype Strategy**: `docs/business-logic/prototype-strategy.md` - MVP approach with detailed alert examples
- **Essential Knowledge**: `specs/ai-agents/context/essential-knowledge.md` - Complete project overview
- **Guidelines**: `specs/ai-agents/guidelines.md` - Development practices

---

## Before You Ask Copilot

Check if the answer exists in:

1. The relevant skill file (see table above)
2. The essential context files (see above)
3. The actual code or test examples in the repo

---

## Project Identity

**Application Name**: TBD (Motivation Cloud products are the company's product line, but our app has its own identity)  
**Client**: Link and Motivation Group  
**Type**: Full-stack web application (Hackathon project)  
**Timeline**: Development until 2026/04/05 23:59:00

**Primary Goal**: Build an app that helps project managers prevent delays through intelligent alerts and real-time progress tracking.

---

## Key Reminders for Copilot

- ✅ **DO** ask about specs first before suggesting implementations
- ✅ **DO** remind users to update docs when learning new project information
- ✅ **DO** suggest implementing 4 core pillars features (especially Phase 1 prototype focus)
- ✅ **DO** enforce the dogfooding mindset - would this help our own team?
- ✅ **DO** suggest tests alongside code
- ❌ **DON'T** suggest using `any` in TypeScript
- ❌ **DON'T** suggest manually editing auto-generated files
- ❌ **DON'T** suggest features that don't align with product vision
- ❌ **DON'T** let documentation get stale without reminding to update

---

## Common Tasks

See [quick-start-guide.md](skills/quick-start-guide.md) for step-by-step guidance on:

- Adding a new API endpoint
- Creating a React component
- Setting up a database migration
- Implementing an alert trigger
- Writing tests for new features

---

Generated: 2026/03/04
