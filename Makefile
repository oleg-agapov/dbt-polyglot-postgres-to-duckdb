VENV := .venv
PYTHON := $(VENV)/bin/python
DBT := $(VENV)/bin/dbt
DBT_FLAGS := --profiles-dir .

.PHONY: setup postgres-up postgres-down postgres-build duckdb-build build-all clean

setup:
	python3 -m venv $(VENV)
	$(PYTHON) -m pip install --upgrade pip
	$(PYTHON) -m pip install -r requirements.txt

postgres-up:
	docker compose up -d --wait postgres

postgres-down:
	docker compose down

postgres-build: postgres-up
	$(DBT) build $(DBT_FLAGS) --target postgres --full-refresh

duckdb-build:
	mkdir -p data
	$(DBT) build $(DBT_FLAGS) --target duckdb --full-refresh

build-all: postgres-build duckdb-build

clean:
	$(DBT) clean $(DBT_FLAGS)
	rm -f data/analytics.duckdb data/analytics.duckdb.wal
