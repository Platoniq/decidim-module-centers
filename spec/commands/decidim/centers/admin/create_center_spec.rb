# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Centers
    module Admin
      describe CreateCenter do
        subject { described_class.new(form, current_user) }

        let(:organization) { create :organization }
        let(:current_user) { create :user, organization: organization }
        let(:title) { "Center title" }

        let(:invalid) { false }
        let(:form) do
          double(
            invalid?: invalid,
            title: { en: title },
            current_organization: organization,
          )
        end

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when everything is ok" do
          let(:center) { Center.last }

          it "creates the center" do
            expect { subject.call }.to change(Center, :count).by(1)
          end

          it "sets the title" do
            subject.call
            expect(translated(center.title)).to eq title
          end

          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:create!)
              .with(Center, current_user, kind_of(Hash))
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)

            expect(Decidim::ActionLog.last.resource).to eq center
          end
        end
      end
    end
  end
end
