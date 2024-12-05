# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Centers
    describe CreateOrUpdateRoleUser do
      subject { described_class.new(role, user) }

      let(:organization) { create :organization }
      let(:user) { create :user, organization: organization }
      let(:role) { create :role, organization: organization }

      context "when the user and role organizations are different" do
        let(:other_organization) { create :organization }
        let(:role) { create :role, organization: other_organization }

        it "is not valid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when everything is ok" do
        context "when the user has no role" do
          it "increases the number of role users" do
            expect { subject.call }.to change(RoleUser, :count).by(1)
          end
        end

        context "when the user already has a role" do
          let!(:role_user) { create :role_user, user: user }

          it "does not increase the number of role users" do
            expect { subject.call }.not_to change(RoleUser, :count)
          end
        end
      end
    end
  end
end
