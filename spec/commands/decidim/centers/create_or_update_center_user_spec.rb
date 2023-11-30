# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Centers
    describe CreateOrUpdateCenterUser do
      subject { described_class.new(center, user) }

      let(:organization) { create :organization }
      let(:user) { create :user, organization: organization }
      let(:center) { create :center, organization: organization }

      context "when the user and center organizations are different" do
        let(:other_organization) { create :organization }
        let(:center) { create :center, organization: other_organization }

        it "is not valid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when everything is ok" do
        context "when the user has no center" do
          it "increases the number of center users" do
            expect { subject.call }.to change(CenterUser, :count).by(1)
          end
        end

        context "when the user already has a center" do
          let!(:center_user) { create :center_user, user: user }

          it "does not increase the number of center users" do
            expect { subject.call }.not_to change(CenterUser, :count)
          end
        end
      end
    end
  end
end
