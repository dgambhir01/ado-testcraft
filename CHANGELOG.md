# Changelog

All notable changes to ado-testcraft will be documented here.

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
