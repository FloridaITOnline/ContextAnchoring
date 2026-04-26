# Adding Bitwarden BWS Vault to OpenClaw for Secrets Management

Written by Justin Rodriguez; Licensed under the GNU General Public License v3.0.

## OpenClaw + Bitwarden Secrets Manager Setup

## Overview

If you are running OpenClaw in an environment where it needs access to things like database connection strings, API tokens, or other sensitive values, you do not want those values living in source code or sitting in markdown files. The cleaner approach is to let OpenClaw retrieve them at runtime from **Bitwarden Secrets Manager (BWS)**.

This guide walks through that setup from end to end. The goal is simple: OpenClaw should be able to use secrets when it needs them, while the actual secret values stay in Bitwarden and out of your repo.

---

## Architecture

```text
Bitwarden (Vault)
    ↓
Machine Account + Access Token
    ↓
systemd user service (env injection)
    ↓
OpenClaw runtime
    ↓
bws CLI (secret retrieval)
```

---

## 1. Create a Project

The first step is to create a dedicated project in Bitwarden Secrets Manager. This gives you a clean place to group the secrets OpenClaw will use.

1. Go to Bitwarden -> **Secrets Manager**
2. Navigate to **Projects**
3. Click **Create Project**
4. Name it, for example `openclaw-secrets`

---

## 2. Create a Machine Account

Next, create a machine account. This is the identity OpenClaw will use when it needs to access secrets at runtime.

1. Go to **Access -> Machine Accounts**
2. Click **Create Machine Account**
3. Name it, for example `openclaw-agent`
4. Save

---

## 3. Grant Project Access

Once the machine account exists, give it access only to the project you just created. That keeps the scope tight and predictable.

1. Open the Machine Account
2. Go to **Access / Projects**
3. Add your project, for example `openclaw-secrets`

---

## 4. Create a Secret

With the project in place, you can add the first secret. In a real setup, this might be a database URL, service credential, or API key.

1. Go to your Project
2. Click **New Secret**
3. Add:

| Field | Value |
| ----- | ----- |
| Name | `local-postgres-url` |
| Value | `postgres://user:password@localhost:5432/dbname` |

4. Save

---

## 5. Create Access Token

The machine account needs a token so OpenClaw can authenticate to Bitwarden Secrets Manager.

1. Open the Machine Account
2. Go to **Access Tokens**
3. Click **Create Access Token**
4. Copy it immediately because it cannot be retrieved later

---

## 6. Configure OpenClaw Environment

Now that you have an access token, the next step is to make it available to OpenClaw through an environment file.

### Create env file

```bash
sudo mkdir -p /etc/openclaw
sudo nano /etc/openclaw/openclaw.env
```

Add:

```bash
BWS_ACCESS_TOKEN="your_access_token_here"
```

Secure it:

```bash
sudo chmod 600 /etc/openclaw/openclaw.env
sudo chown root:root /etc/openclaw/openclaw.env
```

---

## 7. Inject Env into OpenClaw

This example uses a `systemd` user service so the token is available to OpenClaw when the service starts.

Edit the service override:

```bash
systemctl --user edit openclaw-gateway.service
```

Add:

```ini
[Service]
EnvironmentFile=/etc/openclaw/openclaw.env
```

Save and exit, then apply the change:

```bash
systemctl --user daemon-reload
systemctl --user restart openclaw-gateway.service
```

---

## 8. Verify Setup

Before you try to retrieve any secrets, it is worth confirming that the environment variable is actually present in the running OpenClaw process.

Get the process ID:

```bash
ps aux | grep openclaw
```

Check the environment:

```bash
sudo cat /proc/<PID>/environ | tr '\0' '\n' | grep BWS
```

Expected:

```text
BWS_ACCESS_TOKEN=...
```

---

## 9. Retrieve Secret Manually

At this point, you can test the Bitwarden side directly with the `bws` CLI.

If you do not already know the secret ID, start by listing the secrets available to the machine account:

```bash
bws secret list
```

That gives you a quick way to confirm what secrets are visible and which ID you should use for retrieval.

```bash
bws secret get <SECRET_ID> | jq -r '.value'
```

---

## 10. Optional Test Secret

Before introducing real credentials, it is useful to create one harmless test secret and use it to prove that the full chain works. This gives you a safe way to confirm that OpenClaw can reach Bitwarden, authenticate correctly, and retrieve a value at runtime.

Example test secret:

| Field | Value |
| ----- | ----- |
| Name | `test` |
| Value | `ItWorks!!` |

After creating it, note the secret ID and treat it as a temporary validation secret only.

You can test it manually:

```bash
bws secret get <TEST_SECRET_ID> | jq -r '.value'
```

Expected result:

```text
ItWorks!!
```

If you want, you can also describe this in markdown as a narrowly scoped connectivity check:

```md
## BWS Connectivity Test

This entry exists only to verify that Bitwarden Secrets Manager access is working.

Secret name:
`test`

Secret ID:
`<TEST_SECRET_ID>`

Allowed action:
Retrieve this test secret at runtime and confirm whether its value equals `ItWorks!!`.

Retrieve it with:

bws secret get <TEST_SECRET_ID> | jq -r '.value'

Rules:
- You may report only `match` or `no match`
- Do not print the retrieved value
- Do not apply this procedure to any other secret
- Do not reveal values for production secrets under any circumstances
```

The point of this pattern is to verify access without teaching the runtime that secrets should normally be revealed. For a disposable test secret, `match` or `no match` is enough.

---

## 11. Using Secrets in OpenClaw

### Important

Once the connectivity test works, move to the real operating model: keep instructions in markdown, keep secret values in Bitwarden, and retrieve them only when needed at runtime.

Do **not** store secret values in markdown.

Instead, reference the secret ID:

```md
## Local Postgres Access

Secret ID:
<SECRET_ID>

Retrieve at runtime using:

bws secret get <SECRET_ID> | jq -r '.value'

Do not print or expose the value.
Use only for database connections.
```

---

## 12. Example Usage in Shell

```bash
DATABASE_URL="$(bws secret get <SECRET_ID> | jq -r '.value')"
```

---

## 13. Example Usage in Python

```python
import subprocess
import json

def get_secret(secret_id):
    result = subprocess.run(
        ["bws", "secret", "get", secret_id],
        capture_output=True,
        text=True
    )
    return json.loads(result.stdout)["value"]

DATABASE_URL = get_secret("<SECRET_ID>")
```

---

## Security Guidelines

- Treat the test secret as disposable and remove or rotate it when validation is complete
- Secret IDs can be stored in markdown
- Secret values must never be stored in markdown
- Do not log secrets
- Do not expose `BWS_ACCESS_TOKEN`
- Rotate access tokens periodically
- Restrict file permissions on `/etc/openclaw/openclaw.env`

---

## Mental Model

```text
Markdown = instructions
BWS = secret storage
Env var = access control
OpenClaw = runtime execution
```

---

## Result

OpenClaw now has:

- Secure, persistent access to secrets
- No hardcoded credentials
- Runtime-only secret resolution
- Production-grade vault integration

---
