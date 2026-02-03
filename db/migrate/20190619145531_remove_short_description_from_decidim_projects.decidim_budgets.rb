# frozen_string_literal: true

# This migration comes from decidim_budgets (originally 20170207101750)
# This file has been modified by `decidim upgrade:migrations` task on 2026-02-03 11:53:11 UTC
class RemoveShortDescriptionFromDecidimProjects < ActiveRecord::Migration[5.0]
  def change
    remove_column :decidim_budgets_projects, :short_description
  end
end
