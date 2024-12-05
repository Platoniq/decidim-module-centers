# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Centers
    describe Role do
      subject { role }

      let(:role) { create :role }

      it { is_expected.to be_valid }

      describe "deleted?" do
        subject { role.deleted? }

        context "when not deleted" do
          it { is_expected.to be false }
        end

        context "when deleted" do
          let(:role) { create :role, :deleted }

          it { is_expected.to be true }
        end
      end

      describe "not_deleted" do
        subject { described_class.not_deleted }

        let!(:roles) { create_list :role, 5 }
        let!(:deleted_roles) { create_list :role, 3, :deleted }

        it "returns not deleted roles" do
          expect(subject.count).to be 5
          expect(described_class.count).to be 8
        end
      end
    end
  end
end
