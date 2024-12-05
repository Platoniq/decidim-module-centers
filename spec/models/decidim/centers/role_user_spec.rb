# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Centers
    describe RoleUser do
      subject { role_user }

      let(:role_user) { build :role_user }

      it { is_expected.to be_valid }

      describe "same_organization" do
        let(:organization) { create :organization }
        let(:other_organization) { create :organization }
        let(:role) { create :role, organization: organization }
        let(:user) { create :user, organization: other_organization }
        let(:role_user) { build :role_user, role: role, user: user }

        it { is_expected.not_to be_valid }
      end

      describe "unique_by_user" do
        let!(:other_rule_user) { create :role_user }
        let(:role_user) { build :role_user, user: other_rule_user.user }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
