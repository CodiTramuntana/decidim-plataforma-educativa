# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = { git: "https://github.com/CodiTramuntana/decidim.git", branch: "release/0.31-stable" }.freeze

gem "decidim", DECIDIM_VERSION
gem "decidim-cdtb", git: "https://github.com/CodiTramuntana/decidim-module-cdtb.git", branch: "main"
gem "decidim-decidim_awesome", "~> 0.14.0"
gem "decidim-term_customizer", git: "https://github.com/mainio/decidim-module-term_customizer", branch: "release/0.31-stable"

gem "daemons"
gem "delayed_job_active_record"
gem "openssl"
gem "puma"
gem "whenever"

# TODO: Psych problem: https://github.com/laserlemon/figaro/issues/289
# gem "figaro"
gem "dotenv", "~> 3.2.0"

gem "omniauth-entra-id", "~> 3.1.1"

# concurrent-ruby v1.3.5 has removed the dependency on logger
gem "concurrent-ruby"

group :development, :test do
  gem "better_errors"
  gem "binding_of_caller"
  gem "bootsnap"
  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "letter_opener_web"
  gem "listen"
  gem "web-console"
end
