# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Centers
    module Admin
      describe Permissions do
        subject { described_class.new(user, permission_action, context).permissions.allowed? }

        let(:user) { create :user, :admin, organization: organization }
        let(:organization) { create :organization }
        let(:center) { create :center, organization: organization }
        let(:role) { create :role, organization: organization }
        let(:permission_action) { Decidim::PermissionAction.new(**action) }

        context "with center as scope" do
          let(:context) do
            {
              center: center
            }
          end

          context "when scope is admin" do
            let(:action) do
              { scope: :admin, action: :foo, subject: :center }
            end

            it { is_expected.to be true }
          end

          context "when no user" do
            let(:user) { nil }

            let(:action) do
              { scope: :admin, action: :foo, subject: :center }
            end

            it_behaves_like "permission is not set"
          end

          context "when user is not admin" do
            let(:user) { create :user, organization: center.organization }

            let(:action) do
              { scope: :admin, action: :foo, subject: :center }
            end

            it_behaves_like "permission is not set"
          end

          context "when scope is a random one" do
            let(:action) do
              { scope: :foo, action: :foo, subject: :center }
            end

            it_behaves_like "permission is not set"
          end

          context "when subject is a random one" do
            let(:action) do
              { scope: :admin, action: :foo, subject: :foo }
            end

            it_behaves_like "permission is not set"
          end
        end

        context "with role as scope" do
          let(:context) do
            {
              role: role
            }
          end

          context "when scope is admin" do
            let(:action) do
              { scope: :admin, action: :foo, subject: :role }
            end

            it { is_expected.to be true }
          end

          context "when no user" do
            let(:user) { nil }

            let(:action) do
              { scope: :admin, action: :foo, subject: :role }
            end

            it_behaves_like "permission is not set"
          end

          context "when user is not admin" do
            let(:user) { create :user, organization: role.organization }

            let(:action) do
              { scope: :admin, action: :foo, subject: :role }
            end

            it_behaves_like "permission is not set"
          end

          context "when scope is a random one" do
            let(:action) do
              { scope: :foo, action: :foo, subject: :role }
            end

            it_behaves_like "permission is not set"
          end

          context "when subject is a random one" do
            let(:action) do
              { scope: :admin, action: :foo, subject: :foo }
            end

            it_behaves_like "permission is not set"
          end
        end
      end
    end
  end
end
