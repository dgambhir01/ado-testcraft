# ado-testcraft — Claude Code Plugin

## Project Overview

A Claude Code plugin for the QE (Quality Engineering) community that reads Azure DevOps User Stories via MCP and generates structured, professional test cases covering positive, negative, edge, and boundary value scenarios.

**Target audience:** Broader QE / automation engineering community (open source)
**Distribution:** Claude Code plugin marketplace (`claude-plugins-official` submission target)

---

## Plugin Identity

| Field | Value |
| --- | --- |
| **Plugin name** | `ado-testcraft` |
| **Namespace** | Skills invoked as `/ado-testcraft:<skill>` |
| **Version** | `1.0.0` |
| **Author** | Dheeraj Gambhir / [@dgambhir01](https://github.com/dgambhir01) |
| **Homepage** | <https://github.com/dgambhir01/ado-testcraft> |

---

## Directory Structure to Scaffold

```text
ado-testcraft/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest (required)
├── .mcp.json                # Azure DevOps MCP server config
├── skills/
│   └── generate/
│       └── SKILL.md         # Fetch story → generate test cases
├── tests/
│   └── fixtures/
│       └── sample-story.md  # Static mock story for offline testing
├── setup.ps1                # One-time credential setup for end users
├── .gitignore               # Excludes node_modules, OS noise, etc.
├── CHANGELOG.md             # Version history
├── LICENSE                  # MIT license text
├── settings.json            # Default plugin settings
└── README.md                # Setup guide for users
```

> **Important:** `skills/`, `.mcp.json`, and `settings.json` must be at the **plugin root**, NOT inside `.claude-plugin/`. Only `plugin.json` goes inside `.claude-plugin/`.

---

## Plugin Manifest — `.claude-plugin/plugin.json`

```json
{
  "name": "ado-testcraft",
  "description": "Generates structured test cases from Azure DevOps User Stories. Covers positive, negative, edge cases, and boundary values using QE best practices.",
  "version": "1.0.0",
  "author": {
    "name": "Dheeraj Gambhir",
    "url": "https://github.com/dgambhir01"
  },
  "homepage": "https://github.com/dgambhir01/ado-testcraft",
  "repository": "https://github.com/dgambhir01/ado-testcraft",
  "license": "MIT"
}
```

---

## MCP Configuration — `.mcp.json`

Uses environment variables so credentials are **never hardcoded** in plugin files.

Package: [`@azure-devops/mcp`](https://github.com/microsoft/azure-devops-mcp) (official Microsoft package, v2.7.0).

Auth uses `envvar` mode — the package reads `ADO_MCP_AUTH_TOKEN` as a **raw PAT**, no base64 encoding required.

The `-d core work-items` flag scopes the MCP server to only the tools this plugin needs, keeping startup fast.

```json
{
  "mcpServers": {
    "azure-devops": {
      "command": "npx",
      "args": [
        "-y",
        "@azure-devops/mcp@2.7.0",
        "${ADO_ORG}",
        "--authentication",
        "envvar",
        "-d",
        "core",
        "work-items"
      ],
      "env": {
        "ADO_MCP_AUTH_TOKEN": "${ADO_PAT}",
        "ado_mcp_project": "${ADO_PROJECT}"
      }
    }
  }
}
```

---

## Skills

### Skill: `generate` — Core skill (v1 scope)

**File:** `skills/generate/SKILL.md`

```markdown
---
description: Generates structured test cases from an Azure DevOps User Story. Use when the user provides a User Story ID or URL and wants test cases generated.
---

# Generate Test Cases from ADO User Story

## Instructions

The user will provide an Azure DevOps User Story ID (e.g. `12345`) or a full ADO URL.

### Step 0 — Pre-flight checks (before any MCP call)

**Validate input format first.**

- If the input is a plain integer (e.g. `12345`), use it directly as the work item ID.
- If the input is a URL, extract the numeric ID from either of these formats:
  - `https://dev.azure.com/{org}/{project}/_workitems/edit/{id}`
  - `https://{org}.visualstudio.com/{project}/_workitems/edit/{id}`
- If the input is neither a numeric ID nor a recognised ADO URL, stop immediately:
  > "That doesn't look like a valid ADO work item ID or URL. Please provide a numeric ID (e.g. `12345`) or a full Azure DevOps work item URL."

**Validate MCP availability.**

Confirm the Azure DevOps MCP server is connected. If it is not available, stop:

> "The Azure DevOps MCP server is not connected. Please check that ADO_ORG, ADO_PAT, and ADO_PROJECT environment variables are set and restart Claude Code."

### Step 1 — Fetch and validate the work item

Use the Azure DevOps MCP to fetch the work item by ID.

**If the fetch fails or the ID does not exist**, stop:

> "Could not fetch work item [ID]. Please verify the ID is correct and that your PAT has Work Items (Read) permission."

**Check the work item type** (`System.WorkItemType`).

If the type is anything other than `User Story`, stop:

> "Work item [ID] is a [type] — not a User Story. /ado-testcraft:generate only supports User Stories in v1. If you want test cases for a [type], paste the relevant fields here and I can generate them manually."

Types this catches: Bug, Task, Feature, Epic, Test Case, Test Plan, Impediment, Issue, and any custom types.

**Check the work item state** (`System.State`).

- If the state is `Removed`: stop.
  > "Work item [ID] has been removed from this project and cannot be used."
- If the state is `Closed` or `Resolved`: warn and ask before continuing.
  > "User Story [ID] is marked as [state]. Test cases for completed stories may be out of date. Do you want to proceed anyway?"

**Check content richness.**

Evaluate the Title, Description, and Acceptance Criteria fields:

| Situation | Action |
| --- | --- |
| All three fields empty or whitespace only | Stop: "User Story [ID] appears to be empty. Please add a Description or Acceptance Criteria before generating test cases." |
| Title only — Description and AC both empty | Warn and ask: "User Story [ID] has only a title and no description or acceptance criteria. Test cases generated from a title alone will be very generic. Do you want to proceed, or add content to the story first?" |
| Description present, AC empty | Proceed with warning at top of output (see Step 2) |
| AC present (with or without Description) | Proceed normally |

### Step 2 — Fetch fields and note gaps

Fetch:

- Title
- Description
- Acceptance Criteria
- Any linked attachments or comments

If proceeding without Acceptance Criteria, add this note at the top of the output before the table:

> "⚠️ No Acceptance Criteria found — test cases generated from Description only. Recommend confirming AC with dev/PM before finalising."

### Step 3 — Analyze for testable scenarios

Apply the following testing heuristics:

- **Boundary Value Analysis** — test at min, max, just-below-min, just-above-max
- **Equivalence Partitioning** — group valid/invalid inputs into classes
- **SFDIPOT** — Structure, Function, Data, Interfaces, Platform, Operations, Time

### Step 4 — Generate Test Cases

Output a structured markdown table with the following columns:

| # | Test Case Title | Type | Preconditions | Test Steps | Expected Result | Priority |
| --- | --- | --- | --- | --- | --- | --- |

**Types to cover:**

- ✅ Positive — happy path, valid inputs
- ❌ Negative — invalid inputs, error conditions
- 🔲 Edge Case — boundaries, nulls, empty states, max length
- 📐 Boundary Value — exact min/max thresholds

### Step 5 — Summary

After the table, provide:

- Total test cases count by type
- Any areas where acceptance criteria were unclear (flag for QE to verify with dev/PM)
- Suggested automation priority (which cases to automate first)

## Arguments

$ARGUMENTS should be the User Story ID or full ADO URL.
```

---

## Default Settings — `settings.json`

```json
{}
```

Empty for v1 — no configurable options yet. Extend here when you add user-facing settings (e.g. default output format, automation framework target).

---

## User Setup Flow (for README.md)

### Prerequisites

- Claude Code installed and authenticated
- Azure DevOps Personal Access Token (PAT) with **Work Items (Read)** scope

### Step 1 — Create a PAT in Azure DevOps

1. Go to **Azure DevOps → User Settings → Personal Access Tokens**
2. Create a new token with **Work Items (Read)** scope
3. Copy the token value

### Step 2 — Run the setup script

`setup.ps1` writes persistent user-level env vars so Claude Code can connect on every launch.

```powershell
.\setup.ps1
```

Prompts for: organization name, project name, PAT.
Writes: `ADO_ORG`, `ADO_PROJECT`, `ADO_PAT` as user environment variables.

### Step 3 — Install the plugin

```text
/plugin install ado-testcraft@claude-plugins-official
```

### Step 4 — Generate your first test cases

Restart Claude Code, then:

```text
/ado-testcraft:generate 12345
```

---

## Development & Testing Workflow

### Test locally during development

```bash
claude --plugin-dir ./ado-testcraft
```

### Reload after making changes

```text
/reload-plugins
```

### Test the skill

```text
/ado-testcraft:generate 12345
```

For offline testing without a live ADO connection, use the fixture at `tests/fixtures/sample-story.md` as a reference for what the MCP fetch returns, and manually paste the story content when prompted.

### Validate before submitting

```bash
claude plugin validate
```

> Note: Verify that `claude plugin validate` exists in your installed version of Claude Code before relying on it. If not available, manually check that `plugin.json` is valid JSON and all skill files are present.

---

## Submission Plan

1. Build and test locally with `--plugin-dir`
2. Run `claude plugin validate` — fix any issues
3. Push to a public GitHub repo
4. Submit to community marketplace: <https://claude.ai/settings/plugins/submit>
5. After community approval → track record → aim for `claude-plugins-official`

---

## v2 Roadmap (future ideas)

- `/ado-testcraft:coverage-check` — gap analysis against existing test cases
- `/ado-testcraft:push-testcases` — write generated test cases back to ADO Test Plans
- Support Jira as an alternative source (same skills, different MCP)
- `/ado-testcraft:gherkin` — output test cases in BDD / Gherkin format
- `/ado-testcraft:estimate` — estimate test effort from story points
- Support for Epics and Features (not just User Stories)
- `/ado-testcraft:regression-suggest` — given a code change, suggest which existing tests to run

---

## Key Decisions Made

| Decision | Rationale |
| --- | --- |
| Environment variables for ADO credentials | Security — PAT never hardcoded in files |
| Framework-agnostic output (markdown tables) | Works for every QE regardless of stack |
| Validate input format before MCP call | Catches typos and non-ADO IDs early with a clear message, not a cryptic MCP error |
| Check work item type after fetch | ADO shares one ID space across all types; silently generating tests from a Bug or Feature produces misleading output |
| Check work item state (Closed/Removed) | Prevents generating stale tests for completed or deleted stories without user awareness |
| Gate on content richness (title-only, fully empty) | Title-only stories produce useless generic tests; better to ask user to add content first |
| Error handling in generate skill | Actionable messages at every failure point instead of silent failures |
| Test heuristics baked in (SFDIPOT, BVA) | Demonstrates QE domain expertise, better output quality |
| Scoped to User Stories + generate only (v1) | Focused v1; coverage-check and push-testcases in v2 |
| Pin MCP server version | Prevents silent breakage from upstream breaking changes |
