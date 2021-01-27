# Hasura Schema + Metadata Workflow Demo

- [Hasura Schema + Metadata Workflow Demo](#hasura-schema--metadata-workflow-demo)
  - [Introduction](#introduction)
  - [Setup](#setup)
  - [Usage guide](#usage-guide)
  - [Example](#example)
  - [Directory Structure and Comments](#directory-structure-and-comments)
  - [IDE Metadata Intellisense Integration](#ide-metadata-intellisense-integration)

## Introduction

This repo shows an example workflow that can be used for dealing with and managing larger applications/systems, which have many tables and a vast amount of metadata.

It is primarily an organizational/structure-based approach, and centers around co-locating various pieces under a single "model"/"entity".

## Setup

- Clone this repo
- Run `docker-compose up -d`
- You should have Hasura + Postgres running, and available at http://localhost:8080 with some tables and metadata already present

## Usage guide

- Create a folder inside of `/hasura/models` for the entity you want to model, like `user` or `product`
  - Create a file called `table.sql` which has three sections, `/* TABLE */`, `/* FOREIGN KEYS */`, AND `/* TRIGGERS */`
  - Underneath `/* TABLE */` put the table DDL, underneath `/* FOREIGN KEYS */` put FK's as `ALTER TABLE` statements, and underneath `/* TRIGGERS */` put triggers
  - Create a file called `table.yaml`, which has a single object of the same object type you find inside of the `/hasura/metadata/tables.yaml` list of tables, that contains the table's metadata
- From `/hasura/models`, run `make generate_schema_and_tables_metadata` (this just calls both `make generate_sql` and `make generate_tables_yaml`)
- Now, you should have `/hasura/models/schema.sql` and `/hasura.models/tables.yaml`
- Copy the `schema.sql` content over the content of `/hasura/migrations/01_INIT/up.sql`
- Replace `tables.yaml` in `/hasura/metadata` with the newly generated one
- Run `docker-compose down -v` to stop Hasura + Postgres containers, and remove the Postgres data volume (important!)
- Run `docker-compose up -d` to spin them back up, at which point Hasura will automatically try to apply the updated migration + metadata during boot
- Check http://localhost:8080, your schema and metadata should now have the changes you made present =)

## Example

Here's an example of an `address` model with a relationship and permissions:

```sql
-- /hasura/models/address/table.sql

/* TABLE */

CREATE TABLE address (
    id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,

    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL,

    user_id int NOT NULL,

    city text NOT NULL,
    state text NOT NULL,
    -- Use text for zipcode to handle ZIP+4 extended zipcodes
    zipcode text NOT NULL,
    address_line_one text NOT NULL,
    address_line_two text
);

COMMENT ON TABLE address IS
    'A physical billing/shipping address, attached to a user account';

/* FOREIGN KEYS */

ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES public.user (id);

/* TRIGGERS */

CREATE TRIGGER set_address_updated_at
    BEFORE UPDATE ON public.address
    FOR EACH ROW
    EXECUTE FUNCTION public.set_current_timestamp_updated_at();
```

```yaml
# /hasura/models/address/table.yaml
table:
  name: address
  schema: public

object_relationships:
  - name: user
    using:
      foreign_key_constraint_on: user_id

select_permissions:
  - role: user
    permission:
      columns: "*"
      filter: { user_id: { _eq: "X-Hasura-User-Id" } }
```

## Directory Structure and Comments

```sh-session
hasura-schema-metadata-workflow-demo/hasura on master
❯ tree
.
├── config.yaml
├── metadata
│   ├── actions.graphql
│   ├── actions.yaml
│   ├── allow_list.yaml
│   ├── cron_triggers.yaml
│   ├── functions.yaml
│   ├── query_collections.yaml
│   ├── remote_schemas.yaml
│   ├── tables.yaml             <-- Generated tables.yaml from Makefile/Ruby script goes here
│   └── version.yaml
├── migrations
│   └── 01_INIT
│       ├── down.sql
│       └── up.sql              <-- Generated SQL schema from Makefile/Ruby script goes here
├── models
│   ├── Makefile                <-- Run "make help" inside this directory to get a helptext
│   ├── generate-sql.rb         <-- Script that generates combined SQL schema
│   ├── generate-tables-metadata.rb <-- Script that generates combined tables.yaml metadata
│   ├── schema.sql  <-- Output of script, to be copied over INIT migration
│   ├── tables.yaml <-- Output of script to be copied over tables.yaml
│   ├── 00-Misc-SQL-Functions
│   │   └── table.sql
│   ├── address
│   │   ├── table.sql
│   │   └── table.yaml
│   ├── category
│   │   ├── table.sql
│   │   └── table.yaml
│   ├── product             <---- List of "models", which contain their SQL DDL + Metadata
│   │   ├── table.sql
│   │   └── table.yaml
│   ├── product_category
│   │   ├── table.sql
│   │   └── table.yaml
│   └── user
│       ├── table.sql
│       └── table.yaml
└── seeds
```

## IDE Metadata Intellisense Integration

The `.vscode` folder has been set up automatically to provide intellisense when editing metadata files in this project.

For more information, or information about how to configure this for other IDE's (IE, Jetbrains/IntelliJ), please see:

https://github.com/hasura/graphql-engine/tree/master/contrib/metadata-types#metadata-ide-type-checking-integration
