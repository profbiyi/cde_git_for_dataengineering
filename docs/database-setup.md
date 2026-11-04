# Instructor database setup

## 1. Provision and seed

Create a free PostgreSQL service and wait until it is Running. Aiven free services
can power off when unused; power on before lessons and allow rebuilding to finish.
The service must accept connections from GitHub-hosted runners.

Install `requirements-ci.txt`, set `DATABASE_URL` to the administrator connection
URL in your shell, then run:

```bash
python scripts/run_postgres_sql.py bootstrap
```

This creates source tables, inserts a small fictional ecommerce dataset without
overwriting existing rows, and creates `cde_ci` and `cde_deploy` login roles.
It also removes public CREATE access on the public schema. Use a dedicated class
database rather than a database used by other applications.

Using an admin psql session, set distinct passwords without saving them in SQL:

```text
\password cde_ci
\password cde_deploy
```

Keep the admin credential outside Actions. CI can create schemas and read `raw`,
but cannot alter source tables or deployment-owned schemas. Deployment owns only
`staging` and `analytics` and can read `raw`. Both roles have no elevated membership.
New raw tables created by the bootstrap admin inherit SELECT permissions.

## 2. Configure GitHub Actions

Create repository Actions secrets:

| Secret | Contents |
| --- | --- |
| `POSTGRES_CI_URL` | Connection URI for `cde_ci`, with SSL enabled |
| `POSTGRES_DEPLOY_URL` | Connection URI for `cde_deploy`, with SSL enabled |
| `WEEKLY_RELEASE_SSH_KEY` | Existing release deploy key; retain its current protection configuration |

Aiven URLs use the service hostname, service port and `defaultdb`. Percent-encode
special characters in URI passwords. Never add URLs or passwords to Git.

Initialize the persistent views once using the deployment role:

```bash
python scripts/run_postgres_sql.py deploy --schema staging
python scripts/run_postgres_sql.py deploy --schema analytics
```

Verify that the staging branch protection requires the updated check named
`Validate PostgreSQL SQL` and two approvals. Replace any old Snowflake required
check name, otherwise merges will wait for a check that no longer exists.
The PostgreSQL deployment is active only after these workflow changes merge.
Remove unused Snowflake secrets/variables after the migration is confirmed.

## 3. PR and release lifecycle

PR validation uses a unique schema per run. Its complete transaction is rolled
back on success or failure, including schema creation. PostgreSQL also rolls it
back if the client connection dies; no close-event workflow or scheduled schema
sweeper is required for this design. Statement timeouts bound individual SQL work.
Validation jobs share a concurrency group to reduce connection pressure. GitHub
may replace older pending runs; checks must pass for the PR's latest commit.

Merges to staging deploy persistent staging views. Tuesday/manual releases deploy
analytics, test it, and only then fast-forward main. A rejected Git push after a
successful database deployment requires rerunning the release; the two systems
cannot commit atomically. The release reads one pinned staging commit throughout.

Keep student SQL limited to view definitions and SELECT tests. Do not include
transaction control statements or schema-qualified output views. Shared raw data
is deliberately stable; changing it can affect all open PRs.

## Local verification without a cloud account

A local PostgreSQL instance can exercise the same runner and role permissions.
Bootstrap it with an admin connection, then validate using `cde_ci`, and deploy
using `cde_deploy`. Use only disposable development data for failure experiments.
