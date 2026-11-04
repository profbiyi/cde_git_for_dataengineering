-- Run as the instructor/admin. Set login passwords separately, never in Git.
DO $$ BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'cde_ci') THEN
        CREATE ROLE cde_ci LOGIN;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'cde_deploy') THEN
        CREATE ROLE cde_deploy LOGIN;
    END IF;
END $$;

REVOKE CREATE ON SCHEMA public FROM PUBLIC;
-- Database name varies by provider; grant on the connected database safely.
DO $$ BEGIN
    EXECUTE format('GRANT CONNECT, CREATE ON DATABASE %I TO cde_ci', current_database());
    EXECUTE format('GRANT CONNECT ON DATABASE %I TO cde_deploy', current_database());
END $$;
GRANT USAGE ON SCHEMA raw TO cde_ci, cde_deploy;
GRANT SELECT ON ALL TABLES IN SCHEMA raw TO cde_ci, cde_deploy;
ALTER DEFAULT PRIVILEGES IN SCHEMA raw
    GRANT SELECT ON TABLES TO cde_ci, cde_deploy;
ALTER SCHEMA staging OWNER TO cde_deploy;
ALTER SCHEMA analytics OWNER TO cde_deploy;
