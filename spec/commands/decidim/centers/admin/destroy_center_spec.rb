# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Centers
    module Admin
      describe DestroyCenter do
        subject { described_class.new(center, current_user) }

        let(:organization) { create :organization }
        let(:current_user) { create :user, organization: organization }
        let(:center) { create :center, organization: organization }

        context "when everything is ok" do
          it "updates the deleted_at" do
            expect(center.deleted?).to be false
            subject.call
            expect(center.deleted?).to be true
          end

          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:update!)
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)

            expect(Decidim::ActionLog.last.resource).to eq center
          end
        end
      end
    end
  end
end
