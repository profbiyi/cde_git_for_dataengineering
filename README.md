# CDE Git for Data Engineering

A teaching repository for practising a protected Git workflow used by data engineering teams.

## Branch layers

```text
feature/*  →  staging  →  main
               │           │
               │           └─ production-ready code
               └─ integrated code for testing
```

- `main`: production-ready code.
- `staging`: integration and pre-production testing.
- `feature/*`, `fix/*`, and `docs/*`: short-lived working branches created from `staging`.

## Developer workflow

```bash
git switch staging
git pull origin staging
git switch -c feature/my-change

# Make and inspect changes
git status
git diff

# Save and publish the work
git add <files>
git diff --staged
git commit -m "Describe the change"
git push -u origin feature/my-change
```

Open a pull request from the feature branch into `staging`. The pull request must receive two approvals before it can be merged.

Production releases use a separate pull request from `staging` into `main`.

## Production releases

Every Tuesday at 10:00 in the `Europe/Paris` timezone, GitHub Actions fast-forwards `main` to `staging`. After a release, both branches point to the same commit. If production already contains every staging commit, the workflow exits without creating an empty release commit.

The repository owner, `profbiyi`, may also open a `staging` to `main` pull request at any time and merge it without approvals. Other contributors cannot bypass the production rules.

## Rules

- Never push directly to `staging` or `main`.
- Never force-push to protected branches.
- Resolve all review conversations before merging.
- New commits invalidate earlier approvals.
- Use small commits with descriptive messages.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the complete workflow.
