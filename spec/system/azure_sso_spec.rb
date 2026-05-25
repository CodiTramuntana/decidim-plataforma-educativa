# frozen_string_literal: true

require "spec_helper"

describe "Azure SSO" do
  let(:organization) { create(:organization) }
  let(:tid) { "azure_test_tenant_id" }
  let(:oid) { "azure_test_user_oid" }
  let(:uid) { "#{tid}#{oid}" }
  let(:user_email) { "user@azure.example.com" }

  let(:omniauth_hash) do
    OmniAuth::AuthHash.new(
      provider: "entra_id",
      uid: uid,
      info: {
        email: user_email,
        name: "Azure User",
        nickname: "azure_user"
      },
      extra: {
        raw_info: {
          "tid" => tid,
          "oid" => oid,
          "email" => user_email,
          "name" => "Azure User"
        }
      }
    )
  end

  before do
    switch_to_host(organization.host)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:entra_id] = omniauth_hash
    OmniAuth.config.add_camelization("entra_id", "EntraId")
    OmniAuth.config.request_validation_phase = ->(env) {} if OmniAuth.config.respond_to?(:request_validation_phase)
  end

  after do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:entra_id] = nil
    OmniAuth.config.camelizations.delete("entra_id")
  end

  describe "Azure login button" do
    before { visit decidim.new_user_session_path }

    it "displays the Sign in with Microsoft button linking to the entra_id provider" do
      expect(page).to have_css(".login__omniauth-button--entra[href='/users/auth/entra_id']")
    end
  end

  describe "First login — new user flow" do
    around { |example| perform_enqueued_jobs { example.run } }

    it "creates the user and identity after TOS acceptance and signs them in" do
      visit decidim.new_user_session_path
      find(".login__omniauth-button--entra").click

      # Decidim renders a TOS + newsletter form for new OmniAuth users
      within "#omniauth-register-form" do
        check :registration_user_tos_agreement
        check :registration_user_newsletter
        find("*[type=submit]").click
      end

      # Wait for successful redirect before querying the DB
      expect(page).to have_current_path(decidim.root_path)
      expect(Decidim::Identity.find_by(provider: "entra_id", uid: uid)).to be_present
      expect(Decidim::User.find_by(email: user_email)).to be_present
    end
  end

  describe "Second login — user already exists" do
    before do
      user = create(:user, :confirmed, email: user_email, organization: organization)
      create(:identity, user: user, provider: "entra_id", uid: uid, organization: organization)
    end

    it "signs in the existing user without creating duplicates" do
      visit decidim.new_user_session_path

      previous_user_count = Decidim::User.count
      previous_identity_count = Decidim::Identity.count

      find(".login__omniauth-button--entra").click

      expect(Decidim::User.count).to eq(previous_user_count)
      expect(Decidim::Identity.count).to eq(previous_identity_count)
      expect(page).to have_current_path(decidim.root_path)
    end
  end
end
