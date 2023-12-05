# frozen_string_literal: true

require "spec_helper"

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
            centers: [center_user.center.id]
          }
        end

        context "when everything is ok" do
          it { is_expected.to be_valid }

          it "returns valid metadata" do
            expect(subject.metadata).to eq(metadata)
          end
        end

        context "when the user has no center" do
          let(:user) { create :user }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
