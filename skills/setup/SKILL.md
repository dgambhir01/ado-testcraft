---
description: Configures Azure DevOps credentials for ado-testcraft. Use when the user wants to set up or update their ADO_ORG, ADO_PROJECT, and ADO_PAT, or when generate fails because credentials are missing.
---

# Set Up ado-testcraft Credentials

## Instructions

Detect the user's platform, check whether credentials are already set, then output the exact terminal commands they need to paste. **Never ask the user to type their PAT into the chat** — always use placeholders they replace in the terminal.

### Step 1 — Detect operating system

Run `$env:OS` via PowerShell.

- Returns `Windows_NT` → Windows. Proceed to the **Windows** block in Step 3.
- Returns empty or errors → macOS or Linux. Run `uname` via Bash.
  - Returns `Darwin` → macOS
  - Returns `Linux` → Linux

### Step 2 — Check current credential state

Read the three variables with the platform-appropriate shell:

**Windows (PowerShell):**
```powershell
"ADO_ORG=$($env:ADO_ORG)"; "ADO_PROJECT=$($env:ADO_PROJECT)"; if ($env:ADO_PAT) { "ADO_PAT=[set]" } else { "ADO_PAT=[not set]" }
```

**macOS / Linux (Bash):**
```bash
echo "ADO_ORG=${ADO_ORG}"; echo "ADO_PROJECT=${ADO_PROJECT}"; [ -n "$ADO_PAT" ] && echo "ADO_PAT=[set]" || echo "ADO_PAT=[not set]"
```

Show the user a clear credential status summary, masking the PAT:

> **Current credential state:**
> - `ADO_ORG`: [value, or ⚠️ not set]
> - `ADO_PROJECT`: [value, or ⚠️ not set]
> - `ADO_PAT`: [✅ set, or ⚠️ not set]

If all three are already set, say:
> ✅ All credentials are configured. Test with `/ado-testcraft:generate <story-id>`.
> To update any value, paste the replacement commands below into a terminal and restart Claude Code.

Then still show the setup commands in Step 3 for reference and to support credential updates.

### Step 3 — Output platform-specific setup commands

#### Windows

Tell the user to open **PowerShell** (not Command Prompt) and paste these commands, replacing the placeholder values:

```powershell
[System.Environment]::SetEnvironmentVariable("ADO_ORG",     "your-org-name",     "User")
[System.Environment]::SetEnvironmentVariable("ADO_PROJECT", "your-project-name", "User")
[System.Environment]::SetEnvironmentVariable("ADO_PAT",     "your-pat-here",     "User")
```

> Stored as persistent user-level environment variables — survive reboots. Run once per machine.

#### macOS

Tell the user to open **Terminal** and paste (default profile is `~/.zshrc` — the macOS default since Catalina):

```bash
echo '' >> ~/.zshrc
echo '# ado-testcraft' >> ~/.zshrc
echo 'export ADO_ORG="your-org-name"' >> ~/.zshrc
echo 'export ADO_PROJECT="your-project-name"' >> ~/.zshrc
echo 'export ADO_PAT="your-pat-here"' >> ~/.zshrc
source ~/.zshrc
```

> Replace `~/.zshrc` with `~/.bash_profile` if you use bash. Replace the placeholder values.

#### Linux

Tell the user to open a **terminal** and paste (default profile is `~/.bashrc`):

```bash
echo '' >> ~/.bashrc
echo '# ado-testcraft' >> ~/.bashrc
echo 'export ADO_ORG="your-org-name"' >> ~/.bashrc
echo 'export ADO_PROJECT="your-project-name"' >> ~/.bashrc
echo 'export ADO_PAT="your-pat-here"' >> ~/.bashrc
source ~/.bashrc
```

> Replace `~/.bashrc` with `~/.zshrc` if you use zsh. Replace the placeholder values.

### Step 4 — PAT creation instructions

Always include this block so the user knows where to get a PAT:

> **How to create a PAT in Azure DevOps:**
> 1. Go to **Azure DevOps → User Settings** (avatar, top-right) **→ Personal Access Tokens**
> 2. Click **New Token**
> 3. Set scope: **Work Items → Read**
> 4. Copy the token — Azure DevOps shows it only once

### Step 5 — Restart instructions

Always end with restart instructions — environment variables set via terminal do not take effect in running processes:

> **After pasting the commands in your terminal:**
> - **CLI:** exit and restart the `claude` process
> - **VS Code extension:** close VS Code fully and reopen it — a window reload is **not** enough to pick up new environment variables
>
> Then verify your setup: `/ado-testcraft:generate <your-story-id>`
