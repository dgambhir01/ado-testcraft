# Sample ADO User Story — Offline Test Fixture

Use this file to test `/ado-testcraft:generate` without a live ADO connection.
Paste the content below when Claude Code prompts for story details.

---

## Work Item Fields (as returned by Azure DevOps MCP)

```
System.Id:                  42301
System.WorkItemType:        User Story
System.State:               Active
System.Title:               User can reset their password via email link
System.TeamProject:         MyProject
System.AssignedTo:          Jane Smith
System.CreatedDate:         2026-05-01

System.Description:
  As a registered user who has forgotten their password,
  I want to receive a password reset link via email
  so that I can regain access to my account without contacting support.

  The reset link must expire after 30 minutes.
  The user must set a password that meets the complexity rules:
    - Minimum 8 characters
    - At least one uppercase letter
    - At least one number
    - At least one special character (!@#$%^&*)

Microsoft.VSTS.Common.AcceptanceCriteria:
  1. Given I am on the login page,
     When I click "Forgot Password" and enter a registered email address,
     Then I receive a password reset email within 2 minutes.

  2. Given I click the reset link in the email,
     When the link is less than 30 minutes old,
     Then I am taken to a "Set New Password" page.

  3. Given I am on the "Set New Password" page,
     When I enter a password that meets all complexity rules and confirm it,
     Then my password is updated and I am redirected to the login page with a success message.

  4. Given I attempt to use the same reset link a second time,
     Then I see an error: "This link has already been used. Please request a new one."

  5. Given the reset link is more than 30 minutes old,
     When I click it,
     Then I see an error: "This link has expired. Please request a new password reset."

  6. Given I enter a new password that does not meet complexity rules,
     Then I see an inline validation error listing the unmet requirements.
```

---

## How to use this fixture

When testing locally without MCP, run:

```text
/ado-testcraft:generate 42301
```

If MCP is unavailable, paste the fields above directly into the conversation when prompted.
The skill will treat this as the fetched work item and proceed to generate test cases.
