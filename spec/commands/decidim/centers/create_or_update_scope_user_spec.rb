# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Centers
    describe CreateOrUpdateScopeUser do
      subject { described_class.new(scope, user) }

      let(:organization) { create :organization }
      let(:user) { create :user, organization: organization }
      let(:scope) { create :scope, organization: organization }

      context "when the user and scope organizations are different" do
        let(:other_organization) { create :organization }
        let(:scope) { create :scope, organization: other_organization }

        it "is not valid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when everything is ok" do
        context "when the user has no scope" do
          it "increases the number of scope users" do
            expect { subject.call }.to change(ScopeUser, :count).by(1)
          end
        end

        context "when the user already has a scope" do
          let!(:scope_user) { create :scope_user, user: user }

          it "does not increase the number of scope users" do
            expect { subject.call }.not_to change(ScopeUser, :count)
          end
        end
      end
    end
  end
end
