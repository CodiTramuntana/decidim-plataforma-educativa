## Context

Decidim ships with a pluggable OmniAuth strategy layer. When a provider is registered in the initializer, Decidim's `Decidim::CreateOmniauthRegistration` command handles the full lifecycle: find-or-create user, find-or-create identity, and sign in. No core overrides are needed.

The platform is a greenfield deployment — zero pre-existing users. All accounts will originate from Azure. The client manages access permissions at the Azure portal level (app assignment, conditional access), so Decidim itself does not need a user allowlist.

## Goals / Non-Goals

**Goals:**
- Integrate `omniauth-entra-id` as a single-tenant Azure provider.
- First login: create `Decidim::User` + `Decidim::Authorization` (`Decidim::Identity`) with UID = `tid+oid` (concatenated, no separator — produced natively by the gem).
- Subsequent logins: look up existing identity by UID (OID is stable across aliases/name changes).
- Prevent Azure-registered users from using the email/password sign-in path.
- Keep all credentials out of version control; surface them through environment variables.

**Non-Goals:**
- Multi-tenant support (`common` or `organizations` endpoints).
- Certificate-based authentication (client secret is sufficient for initial deployment).
- Searching by `otherMails` or alternative email addresses.
- Syncing display name or other profile attributes from Azure on each login.
- Any `prepend`, `include`, or monkey-patch on Decidim core modules.

## Decisions

### D1 — UID format: `"#{tid}#{oid}"` (tid+oid concatenation)

The `omniauth-entra-id` v3.x gem computes the UID natively as the concatenation of `tid` and `oid` with no separator. Azure OIDs are unique within a tenant but not globally; prefixing with `tid` ensures uniqueness if the tenant configuration ever changes, and makes the identity record self-describing.

**Alternatives considered:**
- OID alone: collision risk if tenant changes or multi-tenant is added later.
- email: email can change; not a stable identifier.
- `"#{tid}##{oid}"` (with `#` separator): rejected — the gem does not insert a separator, and adding middleware purely for formatting would add complexity for no real benefit.

### D2 — Gem: `omniauth-entra-id` v3.1.1

This is the current maintained library for Microsoft Entra ID (formerly Azure AD v2). It replaces the deprecated `omniauth-azure-activedirectory-v2`. In github: https://github.com/pond/omniauth-entra-id

### D3 — Single-tenant mode (fixed `tenant_id`)

The client's Azure app registration is configured for a single organizational directory. Using a fixed GUID for `tenant_id` ensures only accounts from that tenant can authenticate, providing an implicit security boundary on top of any Azure-side restrictions.

**Alternatives considered:**
- `common` endpoint: allows personal Microsoft accounts, which is undesirable for a corporate platform.

### D4 — Email/password restriction for Azure users

Decidim's `CreateOmniauthRegistration` sets `encrypted_password` to `SecureRandom.hex` (see gem source). The user never receives this value, so the standard Devise sign-in form effectively rejects them — they cannot know their own password.

**Risk:** The Devise password-reset flow allows any user to set a new known password via email link. An Azure-registered user could use this to gain email/password access. Mitigations:
- Accept this gap for v1 (corporate environment, Azure app assignment controls access at the source).
- If stricter enforcement is required in a future iteration, add a before-action on `Devise::PasswordsController` that checks for an existing `entra_id` identity — without monkey-patching the Decidim engine.

**Alternatives considered:**
- Monkey-patching `Decidim::PasswordsController`: violates the no-patch constraint.

### D5 — Button rendering: Decidim 0.30 built-in helper

Decidim 0.30's OmniAuth button helper renders provider buttons automatically. The button has no text — it uses Decidim's default OmniAuth button style, identified by the CSS class `.login__omniauth-button--entra`. No custom view partial or custom CSS is required.

**Alternatives considered:**
- Custom `_omniauth_buttons.html.erb` view override + custom CSS: implemented initially, then deleted when it was confirmed Decidim 0.30's default rendering is sufficient and produces the correct `.login__omniauth-button--entra` CSS class used in tests.

### D6 — Environment variable injection via `figaro` / `secrets.yml`

The project already uses `config/application.example.yml` (Figaro pattern). The three Azure variables (`AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_TENANT_ID`) follow the same convention and are referenced in `config/secrets.yml` under the `omniauth.entra_id` key.

## Risks / Trade-offs

- **Secret rotation**: Rotating `AZURE_CLIENT_SECRET` requires a server restart. → Mitigation: document rotation procedure in ops runbook.
- **Azure app misconfiguration**: If the redirect URI is not registered in Azure, OmniAuth returns a `redirect_uri_mismatch` error. → Mitigation: document the required callback URL (`/users/auth/entra_id/callback`) in the ops runbook and in the Azure app registration setup guide.
- **OID reuse**: Microsoft does not reuse OIDs within a tenant, but if a user account is deleted and recreated, a new OID is issued. → Accepted risk; the old Identity record would remain orphaned and a new one would be created on next login.
- **Password reset gap**: As noted in D4, Azure users could theoretically set a password via Devise's reset flow in v1. → Acceptable for initial deployment given the corporate context; revisit if security audit flags it.

## Migration Plan

1. Merge branch into staging; set the three env vars in the hosting environment.
2. Register the OmniAuth callback URL in the Azure app registration.
3. Smoke-test with a real Azure account on staging.
4. Deploy to production; verify the Azure login button appears on the sign-in page.
5. **Rollback**: remove `AZURE_CLIENT_ID` from the environment; the provider will not initialise and the button will not appear. No database migration required.

## Open Questions

~~Q1: Should the Microsoft logo be served as an inline SVG or as a static asset reference?~~ **Resolved**: static SVG at `app/packs/images/entra_id_logo.svg`, referenced via `icon_path` in `secrets.yml`.

~~Q2: Is the `application.example.yml` the canonical ops reference, or is there a separate secrets management system?~~ **Resolved**: `config/application.example.yml` is the canonical ops reference for this deployment.
