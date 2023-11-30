# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Centers
    module Admin
      describe UpdateCenter do
        subject { described_class.new(form, center, current_user) }

        let(:organization) { create :organization }
        let(:current_user) { create :user, organization: organization }
        let(:title) { "Center title" }
        let(:center) { create :center, organization: organization }
        let(:invalid) { false }
        let(:form) do
          double(
            invalid?: invalid,
            title: { en: title },
            current_organization: organization
          )
        end

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end

          it "doesn't update the center" do
            expect(center).not_to receive(:update!)
            subject.call
          end
        end

        context "when everything is ok" do
          let(:title) { "Center title updated" }

          it "updates the title" do
            subject.call
            expect(translated(center.title)).to eq title
          end

          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:update!)
              .with(center, current_user, { title: { en: title } })
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)

            expect(Decidim::ActionLog.last.resource).to eq center
          end
        end
      end
    end
  end
end
