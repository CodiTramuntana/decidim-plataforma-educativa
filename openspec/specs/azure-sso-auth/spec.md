# Spec: Azure SSO Authentication

## Purpose

Defines authentication behaviour for users who sign in via Azure Entra ID (formerly Azure AD) using OmniAuth. Covers sign-in UI, identity creation, returning-user lookup, alias handling, error cases, and password-login restrictions.

---

## Requirements

### Requirement: Azure login button visible on sign-in page
The login page SHALL display an Azure SSO button (no button text) when the `entra_id` OmniAuth provider is configured via environment variables.

#### Scenario: Button visible when provider configured
- **WHEN** `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, and `AZURE_TENANT_ID` are set
- **THEN** the sign-in page displays the Azure SSO button (`.login__omniauth-button--entra`) without any button text

#### Scenario: Button links to OmniAuth entra_id path
- **WHEN** the user views the sign-in page
- **THEN** the Azure button href is `/users/auth/entra_id`

---

### Requirement: First login creates user and identity
On first successful Azure authentication the system SHALL create a `Decidim::User` record and a linked `Decidim::Identity` record using the OID as the stable identifier.

#### Scenario: New user is created on first Azure login
- **WHEN** a valid Azure token arrives for a user with no existing `Decidim::Identity` with provider `entra_id`
- **THEN** a new `Decidim::User` is created with the email from the Azure token
- **AND** a `Decidim::Identity` is created with `provider: "entra_id"` and `uid: "#{tid}#{oid}"` (tid and oid concatenated without separator, as produced natively by the `omniauth-entra-id` gem)
- **AND** the user is signed in

#### Scenario: User is confirmed without email verification
- **WHEN** a new user is created via Azure SSO
- **THEN** the user record is marked as confirmed (no email confirmation step)

---

### Requirement: Subsequent logins authenticate by OID
On any login after the first, the system SHALL authenticate by looking up the existing `Decidim::Identity` record by UID (`tid+oid` concatenation) without relying on the email address.

#### Scenario: Returning user is signed in by OID
- **WHEN** a valid Azure token arrives for a user whose `Decidim::Identity` already exists with the matching `uid`
- **THEN** no new `Decidim::User` or `Decidim::Identity` is created
- **AND** the existing user is signed in

---

### Requirement: Corporate alias does not affect authentication
Because Microsoft returns the same OID regardless of which alias the user uses to sign in, the system SHALL authenticate alias-using users identically to their primary email login.

#### Scenario: Login with a corporate alias authenticates the same user
- **WHEN** a valid Azure token arrives with a different `email` value but the same `oid` as an existing `Decidim::Identity`
- **THEN** the system finds the identity by UID (`tid+oid` concatenation) and signs in the original user
- **AND** no duplicate user or identity is created

---

### Requirement: Token missing email is rejected with a controlled error
If the Azure token does not include an email address, the system SHALL surface a user-facing error and SHALL NOT create a partial user record.

#### Scenario: Token without email returns an error
- **WHEN** an Azure token arrives with a missing or blank `email` field
- **THEN** the `Decidim::CreateOmniauthRegistration` command broadcasts `:invalid`
- **AND** no `Decidim::User` or `Decidim::Identity` is created
- **AND** the user is redirected to the sign-in page with an error message

---

### Requirement: Azure users cannot sign in with email and password
Users whose only authentication method is Azure SSO SHALL NOT be able to sign in using the Decidim email/password form.

#### Scenario: Azure user cannot sign in with email and password
- **WHEN** a user is created via Azure SSO
- **THEN** Decidim's `CreateOmniauthRegistration` sets a random `encrypted_password` (`SecureRandom.hex`) that the user never receives
- **AND** the standard Devise sign-in form rejects any login attempt because the user has no way to know their password
- **Note**: no explicit test needed — this is Decidim core behaviour, not application code

#### Scenario: Azure user cannot use the password reset flow to gain password access
- **WHEN** an Azure-only user requests a password reset email
- **THEN** the system sends no password reset instructions (Devise behaviour for users with no password column or confirmed via OmniAuth)
