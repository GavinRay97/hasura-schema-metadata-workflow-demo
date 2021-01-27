.PHONY: generate_sql generate_tables_yaml generate_schema_and_tables_metadata

generate_sql: ## Generate single SQL file schema from all models
	ruby ./generate-sql.rb \
		--identifiers '/* TABLE */,/* FOREIGN KEYS */,/* TRIGGERS */' \
		--out schema.sql \
		./**/**.sql

generate_tables_yaml: ## Generate tables.yaml file from all models
	ruby ./generate-tables-metadata.rb \
		--out tables.yaml \
		./**/table.yaml

generate_schema_and_tables_metadata: ## Generate single SQL file schema and tables.yaml from all models
generate_schema_and_tables_metadata: generate_sql generate_tables_yaml

help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help