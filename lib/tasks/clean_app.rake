# frozen_string_literal: true

# rubocop: disable Rails/RakeEnvironment
# rubocop: disable Style/SpecialGlobalVars
namespace :clean_app do
  desc "Add clean app remote repository"
  task :add do
    puts "Adding the clean-app remote..."
    puts `git remote add clean-app ssh://git@github.com/CodiTramuntana/decidim-clean-app.git`
    puts "Done. Your remotes are now..."
    puts `git remote -v`
  end

  desc "Pull changes from clean-app. Syncs from `master` branch by default"
  task :sync, [:branch] do |_task, args|
    puts "Rails.env: #{Rails.env}"
    branch = args.branch || "master"
    puts "1. Pulling from clean-app #{branch} branch..."

    cmd= "git pull clean-app #{branch} --allow-unrelated-histories"
    puts("RUNNING: #{cmd}")
    # execute and capture output
    rs= `#{cmd}`
    puts rs

    puts "RESULT #{$?}"
    if $? == 0
      puts "Syncing done."
    else
      puts "Syncing failed!!!"
    end

    puts "Now you may have to"
    puts "2. Solve conflicts, add them and commit"
    puts "3. bundle install"
    puts "4. bin/rails db:migrate"
  end
end
# rubocop: enable Style/SpecialGlobalVars
# rubocop: enable Rails/RakeEnvironment
