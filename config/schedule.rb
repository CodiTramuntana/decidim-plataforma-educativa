# frozen_string_literal: true

env :PATH, ENV.fetch("PATH", nil)

every 1.day, at: "3:00 am" do
  rake "decidim_meetings:clean_registration_forms"
end

every :monday, at: "3:30 am" do
  rake "tmp:clear"
end

every 1.day, at: "4:00 am" do
  rake "decidim:reminders:all"
end

every :sunday, at: "4:30 am" do
  rake "decidim:delete_download_your_data_files"
end

every 1.day, at: "5:00 am" do
  rake "decidim:metrics:all"
end

every 1.day, at: "6:00 am" do
  rake "decidim:open_data:export"
end

every 1.day, at: "6:30 am" do
  rake "decidim:mailers:notifications_digest_daily"
end

every :sunday, at: "7:00 am" do
  rake "decidim:mailers:notifications_digest_weekly"
end

# every 5.minutes do
#   rake "participatory_processes_phases:enqueue_change_active_step"
# end
