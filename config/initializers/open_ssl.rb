# frozen_string_literal: true

# mail gem does not allow setting the ssl version:
# https://github.com/mikel/mail/issues/659#issuecomment-301981538
# we set it globally here as a workaround

require 'net/smtp'
ctx= Net::SMTP.default_ssl_context
ctx.min_version= OpenSSL::SSL::TLS1_2_VERSION 
ctx.max_version= nil
