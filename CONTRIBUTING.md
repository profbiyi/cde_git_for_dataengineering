# Contributing

## 1. Start from the latest staging branch

```bash
git switch staging
git pull origin staging
```

## 2. Create a short-lived branch

```bash
git switch -c feature/short-description
```

Use one of these prefixes:

- `feature/` for new functionality
- `fix/` for corrections
- `docs/` for documentation
- `chore/` for maintenance

## 3. Inspect, stage, and commit

```bash
git status
git diff
git add <files>
git diff --staged
git commit -m "Clear description of the change"
```

## 4. Push and open a pull request

```bash
git push -u origin feature/short-description
```

Set the pull request base branch to `staging`. A pull request needs two approvals and all conversations must be resolved before merging.

## 5. Release to production

After changes have been tested on `staging`, open a pull request from `staging` to `main`. Do not push or merge feature branches directly into `main`.
