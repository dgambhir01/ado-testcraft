# ado-testcraft

A Claude Code plugin that reads Azure DevOps User Stories and generates structured, professional test cases — covering positive, negative, edge case, and boundary value scenarios — using QE best practices.

## What it does

Provide a User Story ID or URL. The plugin fetches the story from Azure DevOps and outputs a ready-to-use test case table with:

- Test case title, type, preconditions, steps, expected result, and priority
- Coverage across positive, negative, edge case, and boundary value scenarios
- A summary with automation priority suggestions

## Prerequisites

- [Claude Code](https://claude.ai/code) installed and authenticated
- An Azure DevOps Personal Access Token (PAT) with **Work Items (Read)** scope

## Setup

### 1 — Create a PAT in Azure DevOps

1. Go to **Azure DevOps → User Settings → Personal Access Tokens**
2. Create a new token with **Work Items (Read)** scope
3. Copy the token value

### 2 — Run the setup script

```powershell
.\setup.ps1
```

You will be prompted for your organization name, project name, and PAT. The script stores them as user-level environment variables that survive reboots — no encoding, no profile editing.

### 3 — Install the plugin

```text
/plugin install ado-testcraft@claude-plugins-official
```

### 4 — Generate your first test cases

Restart Claude Code, then:

```text
/ado-testcraft:generate 12345
```

Or with a full ADO URL:

```text
/ado-testcraft:generate https://dev.azure.com/myorg/myproject/_workitems/edit/12345
```

## What the plugin validates before generating

| Check | Behaviour |
| --- | --- |
| Invalid input format | Stops before calling ADO — clear format message |
| Work item doesn't exist | Stops with ID and permission hint |
| Wrong type (Bug, Task, Feature, etc.) | Stops — only User Stories supported in v1 |
| Story is Removed | Stops — item is gone from the project |
| Story is Closed or Resolved | Warns and asks before continuing |
| Story is completely empty | Stops — nothing to generate from |
| Story has title only, no description/AC | Warns content is too sparse, asks to confirm |
| Story has description but no AC | Proceeds with a visible warning in the output |

## Output format

```text
⚠️ No Acceptance Criteria found — test cases generated from Description only.
   Recommend confirming AC with dev/PM before finalising.

| # | Test Case Title | Type | Preconditions | Test Steps | Expected Result | Priority |
|---|---|---|---|---|---|---|
| 1 | Valid login with correct credentials | ✅ Positive | User is registered | ... | User is logged in | High |
| 2 | Login with incorrect password | ❌ Negative | User is registered | ... | Error message shown | High |
...

Summary
- Positive: 4  Negative: 5  Edge: 3  Boundary: 2  — Total: 14
- Suggested automation priority: TC-1, TC-2, TC-7
```

## Offline testing

A sample User Story fixture is included at [`tests/fixtures/sample-story.md`](tests/fixtures/sample-story.md) for testing without a live ADO connection.

## Development

```bash
# Run Claude Code with this plugin loaded locally
claude --plugin-dir ./ado-testcraft

# After making changes to skill files
/reload-plugins

# Test the skill
/ado-testcraft:generate 12345
```

## Roadmap

- `/ado-testcraft:coverage-check` — gap analysis against existing test cases
- `/ado-testcraft:push-testcases` — write generated test cases back to ADO Test Plans
- Gherkin / BDD output format
- Jira support
- Epic and Feature support

## License

[MIT](LICENSE)
