# frozen_string_literal: true

require "spec_helper"

# These specs test the four Azure SSO scenarios using Decidim's standard
# CreateOmniauthRegistration command with the entra_id provider.
#
# The uid format "#{tid}#{oid}" (tid+oid concatenation) is produced natively
# by omniauth-entra-id v3.x and stored as the Identity uid.

module Decidim
  describe CreateOmniauthRegistration do
    describe "#call" do
      let(:organization) { create(:organization) }
      let(:provider)     { "entra_id" }
      let(:tid)          { "azure_test_tenant_id" }
      let(:oid)          { "azure_test_user_oid" }
      let(:uid)          { "#{tid}#{oid}" }
      let(:email)        { "user@azure.example.com" }
      let(:verified_email) { email }
      let(:oauth_signature) { OmniauthRegistrationForm.create_signature(provider, uid) }

      let(:form_params) do
        {
          "user" => {
            "provider"        => provider,
            "uid"             => uid,
            "email"           => email,
            "email_verified"  => true,
            "name"            => "Azure User",
            "nickname"        => "azure_user",
            "oauth_signature" => oauth_signature,
            "tos_agreement"   => "1"
          }
        }
      end

      let(:form) do
        OmniauthRegistrationForm
          .from_params(form_params)
          .with_context(current_organization: organization)
      end

      let(:command) { described_class.new(form, verified_email) }

      context "when first login — no existing identity" do
        it "broadcasts :ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "creates one User and one Identity" do
          expect { command.call }
            .to change(User, :count).by(1)
            .and change(Identity, :count).by(1)
        end

        it "stores the Identity with the correct uid and provider" do
          command.call
          identity = Identity.find_by(provider: provider, uid: uid)
          expect(identity).to be_present
          expect(identity.organization).to eq(organization)
        end

        it "confirms the new user immediately" do
          command.call
          expect(User.find_by(email: email)).to be_confirmed
        end
      end

      context "when second login — identity already exists with the same uid" do
        before do
          user = create(:user, email: email, organization: organization)
          create(:identity, user: user, provider: provider, uid: uid)
        end

        it "broadcasts :ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "does not create a new User" do
          expect { command.call }.not_to change(User, :count)
        end

        it "does not create a new Identity" do
          expect { command.call }.not_to change(Identity, :count)
        end

        it "returns the existing user" do
          existing_user = User.find_by(email: email)
          command.call do
            on(:ok) { |user| expect(user).to eq(existing_user) }
          end
        end
      end

      context "when login with a corporate alias — same uid, different email" do
        let(:primary_email) { "primary@azure.example.com" }
        let(:alias_email)   { "alias@azure.example.com" }
        let(:email)         { alias_email }
        let(:verified_email) { alias_email }

        before do
          user = create(:user, email: primary_email, organization: organization)
          create(:identity, user: user, provider: provider, uid: uid)
        end

        it "broadcasts :ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "does not create a duplicate User" do
          expect { command.call }.not_to change(User, :count)
        end

        it "does not create a duplicate Identity" do
          expect { command.call }.not_to change(Identity, :count)
        end

        it "returns the original user, not a new one" do
          original_user = User.find_by(email: primary_email)
          command.call do
            on(:ok) { |user| expect(user).to eq(original_user) }
          end
        end
      end

      context "when the Azure token is missing an email" do
        let(:email)          { nil }
        let(:verified_email) { nil }

        let(:form_params) do
          {
            "user" => {
              "provider"        => provider,
              "uid"             => uid,
              "email"           => nil,
              "email_verified"  => false,
              "name"            => "Azure User",
              "nickname"        => "azure_user",
              "oauth_signature" => oauth_signature,
              "tos_agreement"   => "1"
            }
          }
        end

        it "broadcasts :invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "does not create any User" do
          expect { command.call }.not_to change(User, :count)
        end

        it "does not create any Identity" do
          expect { command.call }.not_to change(Identity, :count)
        end
      end
    end
  end
end
