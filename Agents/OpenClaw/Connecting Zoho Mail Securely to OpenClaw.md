# Connecting Zoho Mail Securely to OpenClaw

Written by Justin Rodriguez

Licensed under the GNU General Public License v3.0.

This guide documents how to integrate Zoho Mail with OpenClaw so agents can send email, and optionally read email, without exposing credentials directly in prompts, skills, or markdown.

---

## Overview

The goal is to allow OpenClaw agents to:

- Send emails through Zoho SMTP
- Optionally read emails through IMAP or POP
- Avoid exposing credentials directly in prompts or skills
- Maintain secure, auditable automation

In practice, the cleanest setup is to keep email credentials outside the skill itself and inject them at runtime through environment variables or a secret manager such as Bitwarden.

If you are using Bitwarden for secret injection, see:
[Adding Bitwarden BWS Vault to OpenClaw for Secrets Management](https://github.com/FloridaITOnline/ContextAnchoring/blob/a71b7ebd912814a726183b7fe81a48eaffb945bf/Agents/OpenClaw/Adding%20Bitwarden%20BWS%20Vault%20to%20OpenClaw%20for%20Secrets%20Management.md)

---

## Architecture

```text
OpenClaw Agent
   ↓
Skill (Python / Shell / Tool)
   ↓
Zoho SMTP (smtp.zoho.com)
   ↓
Recipient Inbox
```

Secrets are injected through environment variables or a secret manager. A secret manager is the stronger option because it keeps credentials out of the repo and out of static skill files.

---

## 0. Generate Zoho OAuth Credentials

For a production-grade integration, use OAuth 2.0 instead of relying only on a basic SMTP app password. This gives you a cleaner authentication model and makes it easier to rotate tokens or move the integration into a more automated workflow later.

### Create a Zoho API Client

1. Go to `https://api-console.zoho.com/`
2. Click **Add Client**
3. Choose `Server-based Applications`
4. Fill in the client details:

| Field | Value |
| ----- | ----- |
| Client Name | `OpenClaw Mail Integration` |
| Homepage URL | `http://localhost` or your domain |
| Authorized Redirect URI | `http://localhost` |

After creation, Zoho will give you:

- `CLIENT_ID`
- `CLIENT_SECRET`

Store both securely. These should be treated as credentials, not documentation values.

### Generate an Authorization Code

Next, generate a one-time authorization code from the browser. Replace the placeholder values before opening the URL:

```text
https://accounts.zoho.com/oauth/v2/auth?scope=ZohoMail.messages.ALL&client_id=YOUR_CLIENT_ID&response_type=code&access_type=offline&redirect_uri=http://localhost
```

Log in and approve access.

You will then be redirected to a URL like this:

```text
http://localhost/?code=AUTHORIZATION_CODE
```

Copy the value of the `code` parameter. That authorization code is short-lived and can be used only once to mint tokens.

### Exchange the Authorization Code for Tokens

Use the authorization code to request an access token and a refresh token:

```bash
curl -X POST "https://accounts.zoho.com/oauth/v2/token" \
  -d "code=YOUR_AUTH_CODE" \
  -d "client_id=YOUR_CLIENT_ID" \
  -d "client_secret=YOUR_CLIENT_SECRET" \
  -d "redirect_uri=http://localhost" \
  -d "grant_type=authorization_code"
```

The response will include:

- `access_token`
- `refresh_token`
- `expires_in`
- `token_type`

Save the `refresh_token` carefully. For OpenClaw, that is the important long-lived credential. The `access_token` expires and can be regenerated when needed.

### Refresh an Access Token Later

When the access token expires, use the refresh token to obtain a new one:

```bash
curl -X POST "https://accounts.zoho.com/oauth/v2/token" \
  -d "refresh_token=YOUR_REFRESH_TOKEN" \
  -d "client_id=YOUR_CLIENT_ID" \
  -d "client_secret=YOUR_CLIENT_SECRET" \
  -d "grant_type=refresh_token"
```

If your Zoho account lives outside the US datacenter, replace `accounts.zoho.com` with the correct regional accounts domain for your tenant.

### Store OAuth Values Securely

If you want OpenClaw scripts to retrieve these values at runtime, the same secret-manager pattern works well here too.

Using Bitwarden as an example, store:

- `ZOHO_CLIENT_ID`
- `ZOHO_CLIENT_SECRET`
- `ZOHO_REFRESH_TOKEN`

Then load them only when needed:

```bash
export ZOHO_CLIENT_ID="$(bws secret get zoho_client_id --raw)"
export ZOHO_CLIENT_SECRET="$(bws secret get zoho_client_secret --raw)"
export ZOHO_REFRESH_TOKEN="$(bws secret get zoho_refresh_token --raw)"
```

That keeps the OAuth material out of the skill source and out of the markdown while still making it available to runtime scripts.

### Optional: Using OAuth with SMTP via XOAUTH2

If you want to avoid password-based SMTP authentication entirely, Zoho SMTP can also be used with OAuth access tokens through XOAUTH2.

At a high level, the flow looks like this:

1. Use the refresh token to mint a fresh access token
2. Build the SMTP XOAUTH2 authentication string
3. Pass that token to an SMTP client library that supports XOAUTH2

Conceptually, the auth string looks like this before encoding:

```text
user=EMAIL\1auth=Bearer ACCESS_TOKEN\1\1
```

That value is then base64-encoded and sent as the SMTP authentication payload.

This is the more advanced route, and it depends on your SMTP library supporting XOAUTH2 cleanly. For many smaller or single-user setups, an app password is simpler and easier to maintain.

### Recommendation

- Use app passwords for simple setups
- Use OAuth 2.0 for multi-user systems
- Use OAuth 2.0 for production deployments
- Use OAuth 2.0 for anything exposed externally

---

## 1. Prepare Zoho Mail

Before OpenClaw can send mail, Zoho has to be configured to allow SMTP access.

### Enable SMTP Access

In Zoho Mail:

1. Go to `Settings -> Mail Accounts`
2. Enable SMTP
3. Confirm the following settings:

| Setting | Value |
| ------- | ----- |
| SMTP Server | `smtp.zoho.com` |
| Port | `465` for SSL or `587` for TLS |
| Authentication | Required |

### Generate an App Password

If multi-factor authentication is enabled, which it should be, use an app password instead of your primary account password.

1. Go to `Security -> App Passwords`
2. Generate a new app password
3. Save it securely because Zoho will not show it again

---

## 2. Store Credentials Securely

The next step is making the SMTP credentials available to OpenClaw without hardcoding them into the skill.

### Option A: Environment Variables

This is the simplest approach and works well for local testing or controlled environments.

```bash
export ZOHO_SMTP_USER="your-email@domain.com"
export ZOHO_SMTP_PASS="your-app-password"
```

### Option B: Secret Manager

This is the recommended approach for anything more persistent or sensitive.

Using Bitwarden as an example, store:

- `ZOHO_SMTP_USER`
- `ZOHO_SMTP_PASS`

Then inject them at runtime:

```bash
export ZOHO_SMTP_USER="$(bws secret get zoho_user --raw)"
export ZOHO_SMTP_PASS="$(bws secret get zoho_pass --raw)"
```

The exact command may vary depending on how your secret manager names or exposes secret IDs, but the pattern is the same: retrieve the values at runtime and keep them out of the skill source.

If you are using OAuth instead of an app password, apply the same pattern to the OAuth values as well. The important point is that OpenClaw should retrieve credentials at runtime rather than carrying them in the skill itself.

---

## 3. Runtime Secret Retrieval vs Environment Variables

There are two practical ways to get Zoho credentials into OpenClaw, and the difference matters operationally.

### Environment Variables

Environment variables are straightforward, but they require the OpenClaw runtime to inherit the updated shell or service environment correctly. In practice, this often means restarting the OpenClaw service or updating the `systemd` user environment so the new values are actually visible to the skill at runtime.

That works, but it can be inconvenient when you are iterating on credentials or changing secret sources.

### Runtime Retrieval from Referenced Markdown

In this setup, secret retrieval commands such as `bws secret get ...` live inside referenced markdown instructions, and the skill calls those instructions at runtime. That means the skill does not have to rely on the OpenClaw shell environment being refreshed every time a credential changes.

This pattern can be easier to manage because:

- Secrets are resolved only when needed
- The skill does not depend on a refreshed shell session
- Secret material does not have to live in static skill code

The tradeoff is that the runtime needs permission to execute the retrieval command, and the referenced instructions need to stay tightly scoped so the behavior remains predictable.

If your OpenClaw setup already uses Bitwarden-backed markdown references, this can be a cleaner operational model than relying entirely on exported environment variables.

---

## 4. Create an OpenClaw Skill

Once the credentials are available through the environment, create a skill that knows how to send mail through Zoho.

Create a skill directory:

```bash
mkdir -p ~/.openclaw/workspace/skills/send-email-zoho
```

### `SKILL.md`

```md
# Send Email via Zoho

## Description
Sends an email using Zoho SMTP.

## Inputs
- to: recipient email
- subject: subject line
- body: email body

## Constraints
- Must not expose credentials
- Must use environment variables
```

### `send_email.py`

```python
import os
import smtplib
from email.mime.text import MIMEText

def send_email(to, subject, body):
    smtp_server = "smtp.zoho.com"
    port = 465

    user = os.getenv("ZOHO_SMTP_USER")
    password = os.getenv("ZOHO_SMTP_PASS")

    msg = MIMEText(body)
    msg["Subject"] = subject
    msg["From"] = user
    msg["To"] = to

    with smtplib.SMTP_SSL(smtp_server, port) as server:
        server.login(user, password)
        server.send_message(msg)

    return "Email sent successfully"

if __name__ == "__main__":
    import sys

    to = sys.argv[1]
    subject = sys.argv[2]
    body = sys.argv[3]
    print(send_email(to, subject, body))
```

This keeps the logic simple: OpenClaw passes the recipient, subject, and body, while the SMTP identity and password come from the runtime environment.

---

## 5. Register the Skill in OpenClaw

After the skill is in place, make sure OpenClaw can discover it.

```bash
openclaw skills list
```

If needed, restart the service:

```bash
systemctl --user restart openclaw-gateway.service
```

---

## 6. Add Guardrails

Email is a high-impact capability, so this step matters.

Your skill or agent instructions should make the following rules explicit:

- Only send emails when explicitly instructed
- Never include secrets or credentials in the email body
- Validate the recipient before sending
- Refuse ambiguous or underspecified requests

If you plan to let an agent compose email autonomously, add additional approval steps before outbound delivery.

---

## 7. Test the Integration

Once everything is wired up, test the skill directly from the command line before relying on agent-driven email.

From the CLI:

```bash
python send_email.py test@example.com "Test" "Hello from OpenClaw"
```

From an agent:

```text
Send an email to test@example.com with subject "Test" and body "Hello world"
```

If the email arrives and Zoho shows a successful send, the SMTP path is working.

---

## 8. Optional: Enable IMAP for Reading Email

If you also want OpenClaw to read email, enable IMAP in Zoho and extend the skill accordingly.

Zoho IMAP settings:

| Setting | Value |
| ------- | ----- |
| Server | `imap.zoho.com` |
| Port | `993` for SSL |

With IMAP support, you can extend the skill to:

- Poll an inbox
- Trigger workflows based on incoming mail
- Feed email content into memory or downstream processing

---

## Security Considerations

- Never hardcode credentials
- Use app passwords instead of the primary account password
- Restrict skill permissions as much as possible
- Monitor outbound email behavior
- Consider rate limiting and recipient validation

For production use, prefer a dedicated mailbox or service identity rather than a personal email account.

---

## Future Enhancements

- Cron-triggered email reports
- Automated reporting from Postgres to email
- Email-triggered workflows through an IMAP listener
- Retry logic and queueing with something like RabbitMQ
- Credential rotation automation

---

## Summary

You now have:

- Secure SMTP integration with Zoho
- An OpenClaw skill for sending email
- Guardrails to reduce misuse
- A foundation for email-driven automation

---

## License

This document is provided under the terms of the GNU General Public License v3.0.
