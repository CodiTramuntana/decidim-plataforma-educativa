# frozen_string_literal: true

# This migration comes from decidim (originally 20161005153007)
# This file has been modified by `decidim upgrade:migrations` task on 2026-02-03 11:53:11 UTC
class AddDescriptionToOrganizations < ActiveRecord::Migration[5.0]
  def change
    change_table :decidim_organizations do |t|
      t.jsonb :description
    end
  end
end
