# frozen_string_literal: true

require "spec_helper"
require "decidim/centers/test/shared_contexts"

module Decidim
  module Centers
    module Verifications
      describe Center do
        subject { described_class.from_params(attributes) }

        let(:attributes) do
          {
            "user" => user
          }
        end
        let(:user) { center_user.user }
        let(:center_user) { create :center_user }
        let(:metadata) do
          {
            centers: [center_user.center.id],
            roles: [],
            scopes: []
          }
        end

        context "when roles are disabled" do
          include_context "with roles disabled"

          context "when the user has no center" do
            let(:user) { create :user }

            it { is_expected.not_to be_valid }
          end
        end

        context "when scopes are disabled" do
          include_context "with scopes disabled"

          context "when the user has no center" do
            let(:user) { create :user }

            it { is_expected.not_to be_valid }
          end
        end

        context "when roles and scopes are disabled" do
          include_context "with roles disabled"
          include_context "with scopes disabled"

          context "when the user has no center" do
            let(:user) { create :user }

            it { is_expected.not_to be_valid }
          end

          context "when the user has center" do
            it { is_expected.to be_valid }

            it "returns valid metadata" do
              expect(subject.metadata).to eq(metadata)
            end
          end
        end

        context "when roles and scopes are enabled" do
          let(:metadata) do
            {
              centers: [center_user.center.id],
              roles: [role_user.role.id],
              scopes: [scope_user.scope.id]
            }
          end

          context "when the user has center" do
            context "when the user has no scope" do
              it { is_expected.not_to be_valid }
            end

            context "when the user has scope" do
              let!(:scope_user) { create :scope_user, user: user }

              context "when the user has no role" do
                it { is_expected.not_to be_valid }
              end

              context "when the user has role" do
                let!(:role_user) { create :role_user, user: user }

                it { is_expected.to be_valid }

                it "returns valid metadata" do
                  expect(subject.metadata).to eq(metadata)
                end
              end
            end

            context "when the user has role" do
              let!(:role_user) { create :role_user, user: user }

              context "when the user has no scope" do
                it { is_expected.not_to be_valid }
              end

              context "when the user has scope" do
                let!(:scope_user) { create :scope_user, user: user }

                it { is_expected.to be_valid }

                it "returns valid metadata" do
                  expect(subject.metadata).to eq(metadata)
                end
              end
            end
          end
        end
      end
    end
  end
end
