## Why

The Decidim platform lacks federated authentication with Microsoft Azure (Entra ID), preventing corporate users from accessing with their organizational credentials. Since this is a fresh installation with no existing users, this is the natural moment to establish Azure as the primary registration method.

## What Changes

- Add gem `omniauth-entra-id` (v3.1.1) to the Gemfile.
- Register the `entra_id` provider in `config/initializers/azure_entra_id.rb` (single-tenant, client secret).
- Expose `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, and `AZURE_TENANT_ID` in `config/secrets.yml` and document them in `config/application.example.yml`.
- Add the Entra ID logo at `app/packs/images/entra_id_logo.svg`; configure it via `icon_path` in the initializer — Decidim 0.30's built-in OmniAuth button helper renders it automatically (no custom view override needed).
- The Identity UID is always built as `"#{tid}#{oid}"` (tid+oid concatenation, no separator — produced natively by the gem) to guarantee per-tenant uniqueness.
- Users authenticated via Azure cannot use email/password (restriction enforced at the OmniAuth flow level).
- Unit tests for `Decidim::CreateOmniauthRegistration` covering the four defined scenarios.
- System tests (Capybara) for the Azure button and first/second login flows.

## Capabilities

### New Capabilities

- `azure-sso-auth`: Federated authentication with Microsoft Azure Entra ID via OmniAuth. Covers automatic user registration on first login (creates `User` + `Identity` with OID as UID), direct OID-based lookup on subsequent logins, and the restriction that Azure-authenticated users cannot use email/password.

### Modified Capabilities

(none — no existing specs in the project)

## Impact

- **Gemfile / Gemfile.lock**: new dependency `omniauth-entra-id` ~> 3.1.1.
- **config/initializers/azure_entra_id.rb** (new file): provider registration with environment variables.
- **config/secrets.yml**: three new Azure environment keys.
- **config/application.example.yml**: documentation of variables for the operations team.
- **app/packs/images/entra_id_logo.svg**: Entra ID logo asset for the login button.
- **spec/commands/decidim/create_omniauth_registration_spec.rb**: new unit tests.
- **spec/system/azure_sso_spec.rb**: new system tests.
- No changes to Decidim core and no monkey-patches.
