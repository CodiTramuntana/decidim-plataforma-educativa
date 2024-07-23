# frozen_string_literal: true

workers Integer(ENV.fetch("WEB_CONCURRENCY", nil) || 1)
threads_count = Integer(ENV.fetch("MAX_THREADS", nil) || 5)
threads threads_count, threads_count

# These make it crash on Heroku
# pidfile "tmp/pids/puma.pid"
# state_path "tmp/pids/puma.state"

preload_app!

port ENV.fetch("PORT", nil) || 3000
env = ENV.fetch("RACK_ENV", nil) || ENV.fetch("RAILS_ENV", nil) || :production
environment env

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end
