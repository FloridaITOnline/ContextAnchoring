# Setting Up PostgreSQL + pgvector for OpenClaw on Ubuntu

Written by Justin Rodriguez

This guide shows how to set up PostgreSQL and `pgvector` as a local development memory layer for OpenClaw.

It is not a theory piece. It is an operator guide based on real setup work, including the parts that usually go wrong: creating objects in the wrong database, enabling `pgvector` in the wrong place, misconfigured schema permissions, and environment variables that work in one shell but not in the process that actually runs the app.

Tested on Ubuntu 22.04 with PostgreSQL 17.

The goal is straightforward:

- persistent memory instead of stateless execution
- semantic search through vector similarity
- no dependency on a paid hosted vector database
- full control over schema, permissions, and stored data

This guide is intentionally local-development focused. Where a step is acceptable for local work but not for production, that is called out explicitly.

## License

This document is released under the GNU General Public License v3.0. The full license text is available in [LICENSE](C:/temp/doc/LICENSE).

## What This Setup Actually Does

At a high level, the system works like this:

1. OpenClaw sends text to an embedding model.
2. The model returns a vector representation of that text.
3. OpenClaw stores the original text and its vector in PostgreSQL.
4. When a new query arrives, OpenClaw embeds the query.
5. PostgreSQL uses `pgvector` to find similar stored vectors.
6. OpenClaw injects the relevant results back into the prompt or agent context.

In shorthand:

```text
text -> embedding -> stored in PostgreSQL
query -> embedding -> similarity search -> relevant memory
```

That is the entire memory loop. PostgreSQL is the storage layer. `pgvector` is the similarity-search extension. The embedding model creates vectors. OpenClaw has to orchestrate the whole flow.

## Architecture in One Minute

This setup gives you a practical local memory stack:

- `PostgreSQL` stores memory records and metadata
- `pgvector` stores embeddings and runs similarity queries
- an embedding provider turns text into vectors
- `OpenClaw` decides when to write memory and when to retrieve it

PostgreSQL does not become "AI memory" by itself. It becomes useful only when your application consistently performs all of the following:

- generates embeddings when writing memory
- stores those embeddings in a vector column
- generates embeddings for incoming queries
- retrieves similar records at query time
- injects retrieved results into model context in a controlled way

If you skip that wiring, you do not have memory. You have a database with unused vectors.

## Prerequisites

- Ubuntu
- `sudo` access
- OpenClaw installed and runnable in your local environment
- basic comfort with terminal commands and SQL
- a PostgreSQL package source that includes `pgvector`
- an embedding provider API key

This guide was tested on PostgreSQL 17. PostgreSQL 15 should behave very similarly for the steps covered here, but package names and config paths may differ by version.

## 1. Install PostgreSQL

Update package metadata and install PostgreSQL:

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
```

Start and enable the service:

```bash
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

Verify that PostgreSQL is running:

```bash
sudo systemctl status postgresql
```

If the service is not active, fix that before going any further.

## 2. Install pgvector

PostgreSQL does not support vector storage or similarity search by default. You need the `pgvector` extension.

Install it:

```bash
sudo apt install postgresql-17-pgvector
```

Install the package that matches your PostgreSQL major version, such as `postgresql-15-pgvector` for PostgreSQL 15 or `postgresql-17-pgvector` for PostgreSQL 17.

Open a PostgreSQL shell as the `postgres` superuser:

```bash
sudo -u postgres psql
```

You can enable the extension here if you want, but the important part is enabling it inside the correct target database later:

```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

That statement is database-scoped, not cluster-wide. If you enable it in the wrong database, your application still will not be able to use vector columns where it needs them.

## 3. Create the Database and Application User

Inside `psql`, create a dedicated database and a dedicated role for OpenClaw:

```sql
CREATE DATABASE openclaw_dev;

CREATE USER openclaw_app WITH PASSWORD 'yourpassword';

GRANT ALL PRIVILEGES ON DATABASE openclaw_dev TO openclaw_app;
```

For local development, this is fine. For production, you should narrow privileges and avoid broad grants unless you have a specific operational reason.

## 4. Create a Dedicated Schema and Set Permissions

This is one of the easiest places to make a mess if you move too quickly.

Switch into the target database:

```sql
\c openclaw_dev
```

Create a dedicated schema owned by the application user:

```sql
CREATE SCHEMA openclaw AUTHORIZATION openclaw_app;
```

Grant schema usage and creation rights:

```sql
GRANT USAGE, CREATE ON SCHEMA openclaw TO openclaw_app;
```

Set the default search path for this role in this database:

```sql
ALTER ROLE openclaw_app IN DATABASE openclaw_dev
SET search_path = openclaw, public;
```

That last step matters. Without it, objects may end up in `public` even when you intended to isolate everything in your application schema.

## 5. Enable pgvector in the Correct Database

This is a separate step because it causes a very common failure mode.

Still inside the `openclaw_dev` database, run:

```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

Do not assume that enabling `vector` in the default `postgres` database covers your application database. It does not.

## 6. Configure Client Authentication

OpenClaw needs to connect over TCP using the database name, user, and password you created.

Edit `pg_hba.conf`:

```bash
sudo nano /etc/postgresql/17/main/pg_hba.conf
```

Add this line:

```text
host    openclaw_dev    openclaw_app    127.0.0.1/32    scram-sha-256
```

What that means:

- `host`: allow TCP/IP connections
- `openclaw_dev`: only for the OpenClaw development database
- `openclaw_app`: only for the application role
- `127.0.0.1/32`: local machine only
- `scram-sha-256`: password-based authentication using SCRAM

Restart PostgreSQL:

```bash
sudo systemctl restart postgresql
```

If you are using a different PostgreSQL major version, adjust the config path accordingly.

## 7. Build the Connection String

For local development, the connection string will look like this:

```text
postgresql://openclaw_app:yourpassword@localhost:5432/openclaw_dev
```

Export it into the environment that actually launches OpenClaw:

```bash
export DATABASE_URL="postgresql://openclaw_app:yourpassword@localhost:5432/openclaw_dev"
```

This is a local-development convenience, not a production pattern.

### Do Not Do This in Production

Do not hardcode credentials into application code, shell history, or committed config files.

Use a proper secret source such as:

- Bitwarden Secrets Manager with `bws`
- AWS Secrets Manager
- Azure Key Vault
- another secret-management system already standard in your environment

For example:

```bash
export DATABASE_URL="$(bws secret get your-secret-id)"
```

The mechanism can vary. The important part is that credentials should be injected securely at runtime.

## 8. Configure Embeddings

PostgreSQL stores vectors. It does not generate them.

You need an embedding provider. If your provider uses an API key, export it in the format that provider expects.

For example, if you are using OpenAI:

```bash
export OPENAI_API_KEY="sk-..."
```

That provider credential is used in two separate moments:

- when writing memory, to embed the stored text
- when searching memory, to embed the incoming query

No embedding model means no vector search workflow.

## 9. Validate the Database with a Real Vector Insert and Query

Do not stop after creating a table. A useful validation proves all three of these:

- the schema is writable
- the `vector` type exists in the right database
- similarity search works

Create a test table:

```sql
CREATE TABLE openclaw.test_memory (
  id bigserial PRIMARY KEY,
  content text NOT NULL,
  embedding vector(3)
);
```

This example uses `vector(3)` instead of a production-sized embedding dimension so the test data is readable by hand. In a real embedding workflow, your dimension must match the model you actually use.

Insert a few sample rows:

```sql
INSERT INTO openclaw.test_memory (content, embedding)
VALUES
  ('postgres memory layer', '[0.10,0.20,0.30]'),
  ('vector similarity search', '[0.11,0.19,0.29]'),
  ('completely unrelated record', '[0.90,0.10,0.40]');
```

Now run a nearest-neighbor query:

```sql
SELECT
  id,
  content,
  embedding <-> '[0.10,0.20,0.31]' AS distance
FROM openclaw.test_memory
ORDER BY embedding <-> '[0.10,0.20,0.31]'
LIMIT 2;
```

If the setup is correct, the closest rows should be the first two records, not the unrelated one.

That result proves the important part: vector storage and similarity search both work in the database OpenClaw is supposed to use.

## 10. How OpenClaw Should Use This

The application layer is where memory becomes real.

OpenClaw should do something close to this:

1. accept an interaction or memory candidate
2. send the text to the embedding API
3. store the original text, vector, and any useful metadata in PostgreSQL
4. embed new user queries or agent tasks
5. run a similarity search against stored vectors
6. inject the best matches back into the prompt or reasoning context

A database alone does not produce retrieval. OpenClaw has to decide:

- what counts as memory worth storing
- when to retrieve memory
- how many results to include
- which metadata to track
- how to avoid polluting prompts with irrelevant results

That design work matters as much as the database setup.

## 11. Common Failure Modes

These are the mistakes most likely to waste your time.

### Objects Created in the Wrong Database

Symptom:

```text
schema does not exist
```

Cause:

You created the schema, extension, or table in `postgres` instead of `openclaw_dev`.

Fix:

Create all application objects in the same database your app actually connects to.

### Environment Variables Work in One Shell but Not in Runtime

Symptom:

The connection string or API key exists when you echo it manually, but OpenClaw still fails to connect or embed.

Cause:

You exported variables in one shell, but the application runs under a different shell, service, process manager, IDE configuration, or container runtime.

Fix:

Set `DATABASE_URL` and your embedding-provider credential in the same environment that launches OpenClaw.

### Schema Exists but the App Cannot Write

Symptom:

Permission errors on table creation or inserts.

Cause:

The role has database access but not the right schema permissions.

Fix:

```sql
GRANT USAGE, CREATE ON SCHEMA openclaw TO openclaw_app;
```

### Objects Land in `public` Instead of the App Schema

Symptom:

Tables show up in `public`, or unqualified queries resolve to the wrong schema.

Cause:

The search path was never set.

Fix:

```sql
ALTER ROLE openclaw_app IN DATABASE openclaw_dev
SET search_path = openclaw, public;
```

### pgvector Enabled in the Wrong Database

Symptom:

`vector` type errors even though you already installed the package.

Cause:

You installed the OS package but never enabled the extension in `openclaw_dev`, or you enabled it only in another database.

Fix:

```sql
\c openclaw_dev
CREATE EXTENSION IF NOT EXISTS vector;
```

## 12. Production Considerations

This guide is for local development. Production needs stricter decisions.

At minimum:

- use managed PostgreSQL if that matches your operational model
- avoid publicly exposed databases unless network controls and authentication are tight
- avoid granting broad write access to roles that do not need it
- keep secrets out of code and out of shell history
- define retention and deletion rules for stored memory
- filter or score what gets written so you do not accumulate low-value junk
- cap retrieval counts so memory does not bloat prompts
- monitor CPU, RAM, disk, and query latency
- watch embedding and agent-loop costs

Also think carefully about whether every interaction should be stored. Unfiltered memory systems get noisy fast.

## Final Notes

PostgreSQL plus `pgvector` is a strong local memory stack because:

- you control the schema and permissions
- you avoid vendor lock-in
- you can integrate memory with the rest of your relational data
- you can build retrieval behavior that fits your own application

The tradeoff is that you are responsible for the design. The database will not decide what to store, what to retrieve, or what is actually useful to the model.

If you wire embeddings, storage, and retrieval correctly, this setup becomes more than a database install. It becomes a workable foundation for persistent AI memory in local development.
