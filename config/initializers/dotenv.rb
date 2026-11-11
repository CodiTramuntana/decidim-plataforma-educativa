# frozen_string_literal: true

keys = %w(SECRET_KEY_BASE DB_DATABASE DB_PASSWORD DB_USERNAME)

unless Rails.env.local?
  keys += %w(
    MAILER_SMTP_ADDRESS
    MAILER_SMTP_DOMAIN
    MAILER_SMTP_PORT
    MAILER_SMTP_USER_NAME
    MAILER_SMTP_PASSWORD
    GEOCODER_LOOKUP_API_KEY
  )
end

Dotenv.require_keys(*keys)
