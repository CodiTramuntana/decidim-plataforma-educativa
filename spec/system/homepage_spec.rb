# frozen_string_literal: true

require "spec_helper"

describe "Homepage" do
  include Decidim::SanitizeHelper

  let!(:organization) do
    create(
      :organization,
      name: { en: "Decidim Application" },
      default_locale: :en,
      available_locales: [:ca, :en, :es]
    )
  end
  let!(:hero) { create(:content_block, organization: organization, scope_name: :homepage, manifest_name: :hero, settings: { "welcome_text_ca"=>"Benvinguda a Decidim Application" }) }
  let!(:sub_hero) { create(:content_block, organization: organization, scope_name: :homepage, manifest_name: :sub_hero) }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path(locale: I18n.locale)
  end

  it "renders the home page" do
    # By default there isn't any Content Block enabled, so we search a content from the header
    within ".main-bar" do
      expect(page).to have_content("Help")
    end
  end

  it "loads and shows organization name and main blocks" do
    visit decidim.root_path

    expect(page).to have_content("Decidim Application")

    within "section .hero .hero__title" do
      expect(page).to have_content("Benvinguda a Decidim Application")
    end

    within "section#sub_hero" do
      subhero_msg = translated(organization.description).gsub(%r{</p>\s+<p>}, "<br><br>").gsub(%r{<p>(((?!</p>).)*)</p>}mi, "\\1").gsub(%r{<script>(((?!</script>).)*)</script>}mi, "\\1")
      expect(page).to have_content(subhero_msg)
    end
  end
end
