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

> "The Azure DevOps MCP server is not connected. Please check that ADO_ORG, ADO_PROJECT, and ADO_PAT environment variables are set and restart Claude Code."

**Resolve the project name from the environment.**

Read the `ADO_PROJECT` environment variable using a shell tool and remember the value — you will pass it as the `project` parameter on every MCP tool call to avoid being prompted on each invocation.

- Windows (PowerShell): `$env:ADO_PROJECT`
- macOS / Linux (Bash): `echo $ADO_PROJECT`

If the returned value is empty, stop:

> "ADO_PROJECT environment variable is not set. Please run `setup.ps1` to configure your Azure DevOps credentials."

### Step 1 — Fetch and validate the work item

Use the Azure DevOps MCP to fetch the work item by ID. **Always pass the `project` parameter** with the value resolved in Step 0 — do not let the MCP server elicit it.

**If the fetch fails or the ID does not exist**, stop:

> "Could not fetch work item [ID]. Please verify the ID is correct and that your PAT has Work Items (Read) scope."

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
