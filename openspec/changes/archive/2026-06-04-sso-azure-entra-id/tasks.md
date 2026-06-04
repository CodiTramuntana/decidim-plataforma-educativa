## 1. Dependencies and Configuration

- [x] 1.1 Add `gem "omniauth-entra-id", "~> 3.1.1"` to Gemfile and run `bundle install`
- [x] 1.2 Create `config/initializers/azure_entra_id.rb` registering the `entra_id` provider with `client_id`, `client_secret`, and `tenant_id` from environment variables; `scope: "openid profile email"` and `response_type: "code"` are gem defaults and do not need to be set explicitly
- [x] 1.3 Add `azure_client_id`, `azure_client_secret`, and `azure_tenant_id` keys to `config/secrets.yml` reading from `ENV`
- [x] 1.4 Add the three Azure variables to `config/application.example.yml` with placeholder values under a `# Azure SSO (Entra ID)` comment

## 2. Asset

- [x] 2.1 Add the Entra ID logo SVG file at `app/packs/images/entra_id_logo.svg`

## 3. Unit Tests — CreateOmniauthRegistration

- [x] 3.1 Create `spec/commands/decidim/create_omniauth_registration_spec.rb` (or add a context to the existing file if present) with a shared `azure_auth_hash` factory helper building an OmniAuth hash with `provider: "entra_id"`, `uid: "#{tid}#{oid}"` (tid+oid concatenation, no separator), and an `info.email`
- [x] 3.2 Write test: **first login** — command broadcasts `:ok`, creates one `Decidim::User` and one `Decidim::Identity` with the correct UID
- [x] 3.3 Write test: **second login (same OID)** — command broadcasts `:ok`, does NOT create a new user or identity, signs in the existing user
- [x] 3.4 Write test: **login with corporate alias (same OID, different email)** — command broadcasts `:ok`, finds identity by UID and signs in the same user without duplication
- [x] 3.5 Write test: **token missing email** — command broadcasts `:invalid`, no user or identity is persisted

## 4. System Tests — Capybara

- [x] 4.1 Create `spec/system/azure_sso_spec.rb`; stub OmniAuth with `OmniAuth.config.test_mode = true` and set up a mock `entra_id` auth hash
- [x] 4.2 Write system test: **Azure button visible** — visits the sign-in page, asserts presence of a link/button pointing to `/users/auth/entra_id` and the Entra ID logo
- [x] 4.3 Write system test: **first login full flow** — OmniAuth mock returns a valid auth hash; visits sign-in, clicks Azure button, asserts user is created and signed in (redirected to dashboard)
- [x] 4.4 Write system test: **second login by OID** — pre-create the user and identity; OmniAuth mock returns the same auth hash; asserts user is signed in without duplication

## 5. Verification

- [x] 5.1 Run the full test suite (`bundle exec rspec`) and confirm all new and existing tests pass
- [x] 5.2 Start the development server, set the env vars in `application.yml`, and manually verify the Azure login button appears on the sign-in page
- [x] 5.3 Review `config/application.yml` is listed in `.gitignore` and is not tracked by git
