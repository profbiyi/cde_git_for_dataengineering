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

Production releases promote the tested staging commit using the scheduled release workflow.

## Production releases

Every Tuesday at 10:00 in the `Europe/Paris` timezone, GitHub Actions fast-forwards `main` to `staging`. After a release, both branches point to the same commit. If production already contains every staging commit, the workflow exits without creating an empty release commit.

The repository owner, `profbiyi`, may also run the production-release workflow manually at any time. Manual runs triggered by other collaborators are skipped. Other contributors cannot bypass the production rules.

## Rules

- Never push directly to `staging` or `main`.
- Never force-push to protected branches.
- Resolve all review conversations before merging.
- New commits invalidate earlier approvals.
- Use small commits with descriptive messages.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the complete workflow.

## PostgreSQL workflow

GitHub Actions connects to one hosted PostgreSQL database (for example Aiven).
The instructor provisions the database once using [docs/database-setup.md](docs/database-setup.md).

- `raw`: shared ecommerce source tables; CI and deployment roles can only read them.
- `ci_pr_<number>_<run>_<attempt>`: temporary views for one PR validation.
- `staging`: persistent views deployed after merging into the Git staging branch.
- `analytics`: persistent production views deployed during a release.

View definitions live in `SQL/views`; data assertions live in `SQL/tests`.
A test passes when its SELECT returns zero rows. CI executes view files in
alphabetical order, then runs the tests against the shared source data.

Validation creates its schema inside a transaction and always rolls it back.
A failed test or disconnected runner rolls it back too, so the schema does not
wait until PR merge to be removed. Every new run starts fresh. Never put explicit
transaction commands (`COMMIT`, `ROLLBACK`, `BEGIN`) in student SQL files.

After merging, deployment rebuilds the views and runs the same tests inside one
transaction. Failed deployment rolls back all view changes. Production deployment
must succeed before the release workflow advances main. Git and PostgreSQL do
not share a transaction: if the Git push fails afterwards, rerun the release to
bring the branch up to date.

### Run a validation

Use Python 3.12 and a CI-role connection URL supplied by the instructor:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements-ci.txt
# Set DATABASE_URL securely in your shell; never commit it.
python scripts/run_postgres_sql.py validate
```

The sample data includes completed, pending and cancelled orders, a customer
without orders, and a product without sales. Initial expected completed revenue
is 115.00: 100.00 on January 5 and 15.00 on January 6, 2026.

The class uses branches in this repository. Fork pull requests do not receive
repository secrets and are skipped; an instructor must review and import those
changes before hosted validation. Repository collaborators can change executable
CI code: only trusted class members should have write access. A temporary schema
is isolation for view names, not a sandbox for arbitrary untrusted SQL.
