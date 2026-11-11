# frozen_string_literal: true

# omniauth-entra-id computes uid natively as tid+oid concatenation, which provides
# cross-tenant uniqueness. No custom uid middleware is required.
client_id = ENV.fetch("AZURE_CLIENT_ID") { "azure_test_client_id" if Rails.env.test? }

if client_id.present?
  # Since Decidim 0.31 providers are no longer read from secrets.yml. Registering it here
  # makes Devise define the /users/auth/entra_id route and Decidim render the login button.
  entra_id_config = Decidim.omniauth_providers[:entra_id] = {
    enabled: true,
    client_id: client_id,
    client_secret: ENV.fetch("AZURE_CLIENT_SECRET") { "azure_test_client_secret" if Rails.env.test? },
    tenant_id: ENV.fetch("AZURE_TENANT_ID") { "azure_test_tenant_id" if Rails.env.test? },
    icon_path: ENV.fetch("AZURE_ICON_PATH", "media/images/entra_id_logo.svg")
  }

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider(:entra_id, entra_id_config.except(:enabled).compact)
  end
end
