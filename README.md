# ado-testcraft

A Claude Code plugin that reads Azure DevOps User Stories and generates structured, professional test cases — covering positive, negative, edge case, and boundary value scenarios — using QE best practices.

Works with the **Claude Code CLI** and the **Claude Code VS Code extension**.

## What it does

Provide a User Story ID or URL. The plugin fetches the story from Azure DevOps and outputs a ready-to-use test case table with:

- Test case title, type, preconditions, steps, expected result, and priority
- Coverage across positive, negative, edge case, and boundary value scenarios
- A summary with automation priority suggestions

## Prerequisites

- [Claude Code](https://claude.ai/code) — CLI or VS Code extension — installed and authenticated
- An Azure DevOps Personal Access Token (PAT) with **Work Items (Read)** scope

## Setup

### 1 — Create a PAT in Azure DevOps

1. Go to **Azure DevOps → User Settings → Personal Access Tokens**
2. Create a new token with **Work Items (Read)** scope
3. Copy the token value

### 2 — Configure credentials

Run the setup script from a terminal — it stores your org, project, and PAT as persistent environment variables:

**Windows (PowerShell):**

```powershell
.\setup.ps1
```

**macOS / Linux:**

```bash
chmod +x setup.sh && ./setup.sh
```

- **Windows**: stored as user-level environment variables (survive reboots)
- **macOS/Linux**: written to your shell profile (`~/.zshrc`, `~/.bashrc`, or `~/.profile` — auto-detected). The script outputs the exact file it wrote to; run `source <that file>` after setup, then restart Claude Code.

### 3 — Install the plugin

**CLI:**

```text
/plugin install ado-testcraft@claude-plugins-official
```

**VS Code extension:** type `/manage plugin` in the Claude Code chat panel, search for `ado-testcraft`, and click **Install**.

### 4 — Restart

- **CLI:** restart the `claude` process
- **VS Code extension:** close and reopen VS Code fully — a window reload is not enough to pick up new environment variables and the installed plugin

### 5 — Generate your first test cases

```text
/ado-testcraft:generate 12345
```

Or with a full ADO URL:

```text
/ado-testcraft:generate https://dev.azure.com/myorg/myproject/_workitems/edit/12345
```

---

**Skipped Step 2, or need to update credentials?** Once the plugin is installed and Claude Code has been restarted, run `/ado-testcraft:setup` in the chat panel. It detects your platform and outputs the exact commands to paste into a terminal. Restart Claude Code once more after pasting.

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

## Example output

Given a User Story for a password-reset flow, the plugin generates:

| # | Test Case Title | Type | Preconditions | Test Steps | Expected Result | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Reset password with valid registered email | ✅ Positive | User account exists; user is logged out | 1. Navigate to login page 2. Click "Forgot password" 3. Enter registered email 4. Submit | Reset link email is sent; success message displayed | High |
| 2 | Reset password with unregistered email | ❌ Negative | No account exists for the email | 1. Navigate to "Forgot password" 2. Enter unregistered email 3. Submit | Generic message shown (no account enumeration); no email sent | High |
| 3 | Submit reset form with empty email field | 🔲 Edge Case | User is on the forgot-password page | 1. Leave email field blank 2. Click Submit | Inline validation error: "Email is required" | Medium |
| 4 | Reset link expires after 60 minutes (max TTL) | 📐 Boundary Value | Valid reset link generated | 1. Wait 60 min 2. Click the reset link | Link is invalid; user prompted to request a new one | High |
| 5 | Reset link is valid at 59 minutes (just inside TTL) | 📐 Boundary Value | Valid reset link generated | 1. Wait 59 min 2. Click the reset link 3. Enter new password | Password updated successfully | High |
| 6 | New password identical to current password | ❌ Negative | User has clicked a valid reset link | 1. Enter current password as new password 2. Submit | Error: "New password must differ from current password" | Medium |
| 7 | Reset link can only be used once | 🔲 Edge Case | User has already used the reset link | 1. Click the same reset link again | Link is invalid; user prompted to request a new one | High |

### Summary

- ✅ Positive: 1 · ❌ Negative: 2 · 🔲 Edge Case: 2 · 📐 Boundary Value: 2 — **Total: 7**
- Suggested automation priority: TC-1, TC-2, TC-4, TC-5, TC-7

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
