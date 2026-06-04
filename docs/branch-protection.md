# Branch Protection

Apply these settings to `main` after the CI workflows exist on GitHub.

Required status checks:

- `iOS CI / build-test`
- `Repository Hygiene / hygiene`

Rules:

- Require pull request before merge.
- Require at least 1 approval.
- Dismiss stale approvals after new commits.
- Require conversation resolution.
- Require branches to be up to date before merge.
- Block force pushes.
- Block branch deletion.
- Enforce for administrators.
- Prefer squash merge.

GitHub CLI command:

```bash
gh api \
  --method PUT \
  repos/gabrielvesz11-ship-it/NossaMaternidadeTeste/branches/main/protection \
  --input - <<'JSON'
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "iOS CI / build-test",
      "Repository Hygiene / hygiene"
    ]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false,
    "required_approving_review_count": 1,
    "require_last_push_approval": true
  },
  "restrictions": null,
  "required_conversation_resolution": true,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "lock_branch": false,
  "allow_fork_syncing": true
}
JSON
```

After the repository is renamed to `NossaMaternidade`, update the command path.
