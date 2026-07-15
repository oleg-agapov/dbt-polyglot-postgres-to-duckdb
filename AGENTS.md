# Repository guidance

## Purpose

This repository is a small proof of concept for `dbt-polyglot`. It verifies
that one dbt project containing PostgreSQL-flavoured SQL can run against both
PostgreSQL and DuckDB. The goal is package-level smoke testing and
reproducibility, not exhaustive SQL dialect compatibility testing.

## Architecture

- PostgreSQL 16 runs through `compose.yml` and listens on port 5432 by default.
- DuckDB is embedded and writes its local database to
  `data/analytics.duckdb`.
- `profiles.yml` defines the `postgres` and `duckdb` dbt targets.
- CSV files under `seeds/` provide identical source data to both targets.
- Models under `models/` are written once using PostgreSQL-flavoured SQL.
- `dbt-polyglot` is installed as a Python package and activates itself at
  interpreter startup. It is not installed through `dbt deps`.

The central configuration is in `dbt_project.yml`:

```yaml
+transpile_from: postgres
+transpile_to: "{{ target.type }}"
```

For PostgreSQL this is a no-op because the source and destination dialects
match. For DuckDB, dbt-polyglot transpiles compiled model SQL from PostgreSQL
to DuckDB.

## Development commands

Create the pinned Python environment:

```shell
make setup
```

Build and test one target:

```shell
make postgres-build
make duckdb-build
```

Build and test both targets:

```shell
make build-all
```

Stop PostgreSQL without deleting its named volume:

```shell
make postgres-down
```

Run dbt directly with the repository-local profile:

```shell
.venv/bin/dbt <command> --profiles-dir . --target postgres
.venv/bin/dbt <command> --profiles-dir . --target duckdb
```

## Validation expectations

Changes to models, seeds, dbt configuration, dependency pins, or Docker setup
should be validated against both targets with `make build-all` when Docker is
available. The expected build currently contains two seeds, two staging views,
one mart table, and thirteen tests.

For changes specific to the transpilation path, inspect generated SQL under
`target/compiled/polyglot_demo/` after compiling with the DuckDB target:

```shell
.venv/bin/dbt compile --profiles-dir . --target duckdb
```

Do not commit local runtime artifacts such as `.venv/`, `target/`, `logs/`, or
`data/*.duckdb`.

## Important constraints

- Keep models single-source: do not create separate PostgreSQL and DuckDB
  versions merely to make the demo pass.
- Keep seed inputs shared between targets.
- Preserve exact dependency pins in `requirements.txt` unless intentionally
  testing an upgrade. dbt-polyglot patches a private dbt-core compiler method,
  so dbt upgrades require revalidation.
- DuckDB is a best-effort dbt-polyglot target in version 0.1.1; Spark is the
  package's first-class target. A DuckDB incompatibility may be a package
  limitation rather than an error in this demo.
- Prefer straightforward PostgreSQL syntax that demonstrates transpilation.
  This repository is not intended to become an exhaustive SQLGlot test suite.
