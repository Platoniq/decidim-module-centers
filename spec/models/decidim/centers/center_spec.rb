# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Centers
    describe Center do
      subject { center }

      let(:center) { create :center }

      it { is_expected.to be_valid }

      describe "deleted?" do
        subject { center.deleted? }

        context "when not deleted" do
          it { is_expected.to be false }
        end

        context "when deleted" do
          let(:center) { create :center, :deleted }

          it { is_expected.to be true }
        end
      end

      describe "not_deleted" do
        subject { described_class.not_deleted }

        let!(:centers) { create_list :center, 5 }
        let!(:deleted_centers) { create_list :center, 3, :deleted }

        it "returns not deleted centers" do
          expect(subject.count).to be 5
          expect(described_class.count).to be 8
        end
      end
    end
  end
end
