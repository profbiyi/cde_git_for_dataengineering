#!/usr/bin/env python3
"""Build and test class SQL against a real PostgreSQL database."""
import argparse
import os
import re
from pathlib import Path

import psycopg
from psycopg import sql

ROOT = Path(__file__).resolve().parents[1]


def execute_files(conn, folder):
    files = sorted((ROOT / folder).glob('*.sql'))
    if not files:
        raise RuntimeError(f'No SQL files in {folder}')
    for path in files:
        print(f'Executing {path.relative_to(ROOT)}', flush=True)
        conn.execute(path.read_text())


def run_tests(conn):
    for path in sorted((ROOT / 'SQL/tests').glob('*.sql')):
        print(f'Testing {path.name}', flush=True)
        if conn.execute(path.read_text()).fetchone() is not None:
            raise RuntimeError(f'{path.name}: expected zero failing rows')


def build(conn, schema):
    conn.execute(sql.SQL('SET LOCAL search_path TO {}, pg_catalog').format(sql.Identifier(schema)))
    execute_files(conn, 'SQL/views')
    run_tests(conn)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=['validate', 'deploy', 'bootstrap'])
    parser.add_argument('--schema')
    args = parser.parse_args()
    url = os.environ.get('DATABASE_URL')
    if not url:
        parser.error('DATABASE_URL is required')
    schema = args.schema or os.environ.get('CI_SCHEMA', 'ci_local')
    if args.mode == 'validate' and not re.fullmatch(r'ci_[a-z0-9_]{1,59}', schema):
        parser.error('Validation schema must start with ci_, use lowercase letters/digits/underscores, and fit 63 characters')
    if args.mode == 'deploy' and schema not in ('staging', 'analytics'):
        parser.error('Deployment requires --schema staging or --schema analytics')
    # Errors from libpq can contain connection details. Do not print the DSN or
    # connection exception; GitHub masks secrets but local terminals may not.
    try:
        conn = psycopg.connect(url, connect_timeout=15)
    except psycopg.OperationalError:
        raise SystemExit('Database connection failed. Check service status, credentials, DNS and SSL settings.') from None
    with conn:
        conn.execute("SET LOCAL statement_timeout = '60s'")
        conn.execute("SET LOCAL lock_timeout = '10s'")
        if args.mode == 'bootstrap':
            execute_files(conn, 'SQL/setup')
        elif args.mode == 'validate':
            # DDL is transactional. Nothing is committed, including the schema.
            # A failed test or disconnected runner also rolls everything back.
            conn.execute(sql.SQL('CREATE SCHEMA {}').format(sql.Identifier(schema)))
            build(conn, schema)
            conn.rollback()
            print('Validation passed; temporary schema rolled back.')
        else:
            # Serialize deployments to the same schema across workflows.
            conn.execute('SELECT pg_advisory_xact_lock(hashtext(%s))', ('cde_deploy_' + schema,))
            build(conn, schema)
            print(f'Views and tests passed in {schema}; committing deployment.')


if __name__ == '__main__':
    main()
