## Phase 1 Complete: Add Tailwind Regression Coverage

Fixed the frontend styling regression at the root cause by expanding Tailwind content scanning to include feature-level components and added a direct config regression test so the path cannot be dropped silently again. This phase stayed frontend-only, passed full workspace quality gates, and required no documentation updates.

**Files created/changed:**
- teamdev-2026-front/tailwind.config.ts
- teamdev-2026-front/__tests__/config/tailwind.config.test.ts

**Functions created/changed:**
- Tailwind content configuration

**Tests created/changed:**
- Tailwind config includes `./src/features/**/*.{js,ts,jsx,tsx,mdx}`
- Tailwind config retains the existing critical source scan paths

**Docs synced/created:**
- None

**Review Status:** APPROVED

**Quality Gates Status:** ✅ PASSED (formatter, linter, tests, typecheck)

**Docs Sync Status:** Not needed

**Git Commit Message:**
```
fix(front): scan feature components in Tailwind

Add src/features to Tailwind content scanning so utility
classes used by feature-level components are generated
consistently, and lock the config in with a regression test.
```