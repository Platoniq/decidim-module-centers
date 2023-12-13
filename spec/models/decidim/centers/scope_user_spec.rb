# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Centers
    describe ScopeUser do
      subject { scope_user }

      let(:scope_user) { build :scope_user }

      it { is_expected.to be_valid }

      describe "same_organization" do
        let(:organization) { create :organization }
        let(:other_organization) { create :organization }
        let(:scope) { create :scope, organization: organization }
        let(:user) { create :user, organization: other_organization }
        let(:scope_user) { build :scope_user, scope: scope, user: user }

        it { is_expected.not_to be_valid }
      end

      describe "unique_by_user" do
        let!(:other_scope_user) { create :scope_user }
        let(:scope_user) { build :scope_user, user: other_scope_user.user }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
