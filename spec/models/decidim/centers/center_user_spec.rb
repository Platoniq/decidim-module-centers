# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Centers
    describe Center do
      subject { center_user }

      let(:center_user) { build :center_user }

      it { is_expected.to be_valid }

      describe "same_organization" do
        let(:organization) { create :organization }
        let(:other_organization) { create :organization }
        let(:center) { create :center, organization: organization }
        let(:user) { create :user, organization: other_organization }
        let(:center_user) { build :center_user, center: center, user: user }

        it { is_expected.not_to be_valid }
      end

      describe "unique_center_by_user" do
        let!(:other_center_user) { create :center_user }
        let(:center_user) { build :center_user, user: other_center_user.user }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
