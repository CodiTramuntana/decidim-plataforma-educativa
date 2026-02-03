# frozen_string_literal: true

# This migration comes from decidim (originally 20180123125409)
# This file has been modified by `decidim upgrade:migrations` task on 2026-02-03 11:53:11 UTC
class AddOmnipresentBannerTitleToDecidimOrganizations < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_organizations, :omnipresent_banner_title, :jsonb
  end
end
