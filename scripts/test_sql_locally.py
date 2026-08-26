#!/usr/bin/env python3
"""Run the repository's Snowflake-oriented SQL locally with DuckDB."""

import argparse
import sys
from pathlib import Path

import duckdb


ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / "SQL" / "fixtures" / "ecommerce.sql"
VIEW_DIR = ROOT / "SQL" / "views"
TEST_DIR = ROOT / "SQL" / "tests"


def sql_files(folder: Path):
    files = sorted(folder.glob("*.sql"))
    if not files:
        raise RuntimeError(f"No SQL files found in {folder.relative_to(ROOT)}")
    return files


def run(database: str):
    database_path = ":memory:" if database == ":memory:" else str(Path(database).resolve())
    if database_path != ":memory:":
        Path(database_path).parent.mkdir(parents=True, exist_ok=True)

    conn = duckdb.connect(":memory:")
    try:
        escaped_path = database_path.replace("'", "''")
        conn.execute(f"ATTACH '{escaped_path}' AS CDE_ECOMMERCE")
        # Rebuild saved databases on every run so old objects cannot hide errors.
        conn.execute("DROP SCHEMA IF EXISTS CDE_ECOMMERCE.ANALYTICS CASCADE")
        conn.execute("DROP SCHEMA IF EXISTS CDE_ECOMMERCE.RAW CASCADE")
        conn.execute("CREATE SCHEMA CDE_ECOMMERCE.RAW")
        conn.execute("CREATE SCHEMA CDE_ECOMMERCE.ANALYTICS")
        conn.execute("USE CDE_ECOMMERCE.ANALYTICS")

        # Compatibility for Snowflake's IFF(condition, true, false).
        conn.execute(
            "CREATE OR REPLACE MACRO IFF(condition, when_true, when_false) "
            "AS CASE WHEN condition THEN when_true ELSE when_false END"
        )

        print("Loading local ecommerce fixtures", flush=True)
        conn.execute(FIXTURE.read_text())

        for path in sql_files(VIEW_DIR):
            print(f"Executing {path.relative_to(ROOT)}", flush=True)
            conn.execute(path.read_text())

        failures = []
        for path in sql_files(TEST_DIR):
            print(f"Testing {path.relative_to(ROOT)}", flush=True)
            rows = conn.execute(path.read_text()).fetchmany(10)
            if rows:
                failures.append((path.name, rows))

        if failures:
            for name, rows in failures:
                print(
                    f"FAILED {name}: expected zero rows, received {rows}",
                    file=sys.stderr,
                )
            raise RuntimeError(f"{len(failures)} SQL quality test(s) failed")

        print("Local DuckDB SQL validation passed")
        if database_path != ":memory:":
            print(f"Inspectable database saved to {database_path}")
    finally:
        conn.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--database",
        default=":memory:",
        help="Optional DuckDB file to keep; defaults to an in-memory database",
    )
    args = parser.parse_args()
    run(args.database)
