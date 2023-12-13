# frozen_string_literal: true

require "spec_helper"
require "decidim/centers/test/shared_contexts"

module Decidim
  module Centers
    describe AutoVerificationJob do
      subject { described_class }

      describe "queue" do
        it "is queued to events" do
          expect(subject.queue_name).to eq "default"
        end
      end

      describe "perform" do
        let(:user) { create :user }
        let(:params) { user.id }

        before do
          allow(Rails.logger).to receive(:info).and_call_original
          allow(Rails.logger).to receive(:error).and_call_original
        end

        context "when the user has no center neither scope" do
          it_behaves_like "no authorization is created"

          context "when there is a previous authorization for the user" do
            let!(:authorization) { create :authorization, name: "center", user: user }

            it "removes an authorization" do
              expect { subject.perform_now(params) }.to change(Decidim::Authorization, :count).by(-1)
            end

            context "when the authorization cannot be removed" do
              before do
                # rubocop: disable RSpec/AnyInstance
                allow_any_instance_of(Decidim::Verifications::DestroyUserAuthorization).to receive(:authorization).and_return(nil)
                # rubocop: enable RSpec/AnyInstance
              end

              it "writes an error log" do
                subject.perform_now(params)
                expect(Rails.logger).to have_received(:error).with(/AutoVerificationJob: ERROR: not removed for user/)
              end
            end
          end
        end

        context "when the user has center and scope" do
          let!(:center_user) { create :center_user, user: user }
          let!(:scope_user) { create :scope_user, user: user }

          it "creates an authorization" do
            expect { subject.perform_now(params) }.to change(Decidim::Authorization, :count).by(1)
          end

          context "when the authorization cannot be created" do
            before do
              # rubocop: disable RSpec/AnyInstance
              allow_any_instance_of(Decidim::AuthorizationHandler).to receive(:invalid?).and_return(true)
              # rubocop: enable RSpec/AnyInstance
            end

            it "writes an error log" do
              subject.perform_now(params)
              expect(Rails.logger).to have_received(:error).with(/AutoVerificationJob: ERROR: not created for user/)
            end
          end

          context "when there is a previous authorization for the user" do
            let!(:authorization) { create :authorization, name: "center", user: user }

            it_behaves_like "no authorization is created"
          end
        end

        context "when the user does not exist" do
          let(:params) { -1 }

          it_behaves_like "no authorization is created"

          it "writes an error log" do
            subject.perform_now(params)
            expect(Rails.logger).to have_received(:error).with(/AutoVerificationJob: ERROR: user not found/)
          end
        end
      end
    end
  end
end
