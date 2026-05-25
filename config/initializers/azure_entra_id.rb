# frozen_string_literal: true

# omniauth-entra-id computes uid natively as tid+oid concatenation, which provides
# cross-tenant uniqueness. No custom uid middleware is required.
omniauth_secrets = Rails.application.secrets.dig(:omniauth, :entra_id)

if omniauth_secrets&.dig(:client_id).present?
  client_id = omniauth_secrets[:client_id]
  client_secret = omniauth_secrets[:client_secret]
  tenant_id = omniauth_secrets[:tenant_id]

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider(
      :entra_id,
      {
        client_id: client_id,
        client_secret: client_secret,
        tenant_id: tenant_id,
        icon_path: omniauth_secrets[:icon_path].presence || "media/images/entra_id_logo.svg"
      }.compact
    )
  end
end
