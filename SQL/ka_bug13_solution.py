#!/usr/bin/env python3
"""solve the beans_Validate or deploy Snowflake views stored in SQL/views."""

import argparse
import os
import re
import sys
from pathlib import Path

import snowflake.connector
from cryptography.hazmat.primitives import serialization


ROOT = Path(__file__).resolve().parents[1]
VIEW_DIR = ROOT / "SQL" / "views"
TEST_DIR = ROOT / "SQL" / "tests"


def required(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        raise RuntimeError(f"Missing required environment variable: {name}")
    return value


def private_key_der() -> bytes:
    key = serialization.load_pem_private_key(
        required("SNOWFLAKE_PRIVATE_KEY").encode(), password=None
    )
    return key.private_bytes(
        serialization.Encoding.DER,
        serialization.PrivateFormat.PKCS8,
        serialization.NoEncryption(),
    )


def connect():
    return snowflake.connector.connect(
        account=required("SNOWFLAKE_ACCOUNT"),
        user=required("SNOWFLAKE_USER"),
        private_key=private_key_der(),
        role=required("SNOWFLAKE_ROLE"),
        warehouse=required("SNOWFLAKE_WAREHOUSE"),
        database=required("SNOWFLAKE_DATABASE"),
        session_parameters={"QUERY_TAG": "cde_git_for_dataengineering"},
    )


def sql_files(folder: Path):
    files = sorted(folder.glob("*.sql"))
    if not files:
        raise RuntimeError(f"No SQL files found in {folder.relative_to(ROOT)}")
    return files


def execute_files(conn, folder: Path):
    for path in sql_files(folder):
        print(f"Executing {path.relative_to(ROOT)}", flush=True)
        conn.execute_string(path.read_text())


def run_tests(conn):
    failures = []
    for path in sql_files(TEST_DIR):
        print(f"Testing {path.relative_to(ROOT)}", flush=True)
        cur = conn.cursor()
        cur.execute(path.read_text())
        rows = cur.fetchmany(10)
        if rows:
            failures.append((path.name, rows))
    if failures:
        for name, rows in failures:
            print(f"FAILED {name}: expected zero rows, received {rows}", file=sys.stderr)
        raise RuntimeError(f"{len(failures)} SQL quality test(s) failed")


def safe_ci_schema() -> str:
    raw = os.environ.get("CI_SCHEMA", "CI_LOCAL")
    clean = re.sub(r"[^A-Za-z0-9_]", "_", raw).upper()
    if not clean.startswith("CI_"):
        clean = f"CI_{clean}"
    return clean[:200]


def validate():
    schema = safe_ci_schema()
    conn = connect()
    try:
        cur = conn.cursor()
        cur.execute(f'CREATE SCHEMA IF NOT EXISTS "{schema}"')
        cur.execute(f'USE SCHEMA "{schema}"')
        execute_files(conn, VIEW_DIR)
        run_tests(conn)
        print(f"SQL validation passed in temporary schema {schema}")
    finally:
        try:
            conn.cursor().execute(f'DROP SCHEMA IF EXISTS "{schema}" CASCADE')
        finally:
            conn.close()


def deploy():
    conn = connect()
    try:
        conn.cursor().execute("USE SCHEMA ANALYTICS")
        execute_files(conn, VIEW_DIR)
        print("Production views deployed to CDE_ECOMMERCE.ANALYTICS")
    finally:
        conn.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("mode", choices=["validate", "deploy"])
    args = parser.parse_args()
    validate() if args.mode == "validate" else deploy()
