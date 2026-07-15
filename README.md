# dbt-polyglot: PostgreSQL to DuckDB proof of concept

This project runs the same PostgreSQL-flavoured dbt models against PostgreSQL
and DuckDB. On the DuckDB target, `dbt-polyglot` transpiles the compiled model
SQL from the PostgreSQL dialect to DuckDB during dbt compilation.

The demo intentionally stays small. Its purpose is to verify that the package
installs, activates, compiles, and runs in a normal multi-adapter dbt project.

## Prerequisites

- Python 3.9 or newer
- Docker with Docker Compose
- `make`

## Quick start

```shell
make setup
make build-all
```

Or run each warehouse independently:

```shell
make postgres-build
make duckdb-build
```

PostgreSQL runs in Docker and persists its data in a named volume. DuckDB writes
to `data/analytics.duckdb`. Both targets load the same `users.csv` and
`orders.csv` seeds before building and testing the models.

## What enables transpilation

`dbt-polyglot` is a Python package, not a package installed by `dbt deps`. It is
installed into `.venv` alongside dbt and both adapters. The relevant project
configuration is:

```yaml
models:
  polyglot_demo:
    +transpile_from: postgres
    +transpile_to: "{{ target.type }}"
```

For the `postgres` target the source and destination dialects match, so
dbt-polyglot leaves the SQL alone. For the `duckdb` target it asks SQLGlot to
emit DuckDB SQL.

The models contain familiar PostgreSQL forms such as `value::type`, filtered
aggregates, `date_trunc`, and numeric casts. See the generated SQL after a run
under `target/compiled/polyglot_demo/`.

## Useful commands

```shell
# Verify connections and show installed versions
.venv/bin/dbt debug --profiles-dir . --target postgres
.venv/bin/dbt debug --profiles-dir . --target duckdb
.venv/bin/dbt --version

# Inspect a result
.venv/bin/dbt show --profiles-dir . --target postgres --select user_order_summary
.venv/bin/dbt show --profiles-dir . --target duckdb --select user_order_summary

# Remove containers (the named Postgres volume is retained)
make postgres-down

# Remove the Postgres volume too
docker compose down --volumes
```

Connection settings can be overridden with `POSTGRES_HOST`, `POSTGRES_PORT`,
`POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`, and `DUCKDB_PATH`.

## Expected result

Both builds should seed two CSV files, create two staging views and one mart
table, and pass all schema and data tests. DuckDB is a best-effort target in
dbt-polyglot 0.1.1; Spark is currently the package's first-class target.
