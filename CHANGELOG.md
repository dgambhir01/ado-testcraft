# Changelog

All notable changes to ado-testcraft will be documented here.

## [1.0.1] — 2026-06-06

### Added

- `/ado-testcraft:setup` skill — detects platform, checks current credential state, and outputs exact terminal commands for Windows, macOS, and Linux
- `setup.sh` — interactive credential setup script for macOS and Linux

### Fixed

- `generate` error messages now point to `/ado-testcraft:setup` instead of `setup.ps1` (works for all platforms and VS Code installs)
- VS Code extension install instruction corrected: type `/` → select **Manage plugins** (not `/plugin install`, which is CLI-only)
- Credential setup in README now uses inline commands — works for marketplace installs without cloning the repo
- Stale work item bug: skill now always fetches fresh data; never reuses data from a prior invocation in the same session

---

## [1.0.0] — 2026-06-01

### Added

- `/ado-testcraft:generate` skill — generates structured test cases from an Azure DevOps User Story
- Accepts User Story ID or full ADO URL as input
- Covers positive, negative, edge case, and boundary value test types
- Applies SFDIPOT, Boundary Value Analysis, and Equivalence Partitioning heuristics
- Input validation: rejects non-ADO IDs, wrong work item types (Bug, Task, Feature, etc.), removed stories
- State guard: warns before generating tests for Closed or Resolved stories
- Content richness gate: warns when story has no description or acceptance criteria
- Offline test fixture at `tests/fixtures/sample-story.md`
