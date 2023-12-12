# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Centers
    describe SyncScopeUserJob do
      subject { described_class }

      describe "queue" do
        it "is queued to events" do
          expect(subject.queue_name).to eq "default"
        end
      end

      describe "perform" do
        let(:user) { create :user }
        let(:scope) { create :scope }
        let(:params) { { user_id: user.id, scope_id: scope.id } }

        before do
          allow(Rails.logger).to receive(:info).and_call_original
          allow(Rails.logger).to receive(:error).and_call_original
          subject.perform_now(params)
        end

        context "when the sync runs successfully" do
          it "writes an info log" do
            expect(Rails.logger).to have_received(:info).with(/SyncScopeUserJob: Success/)
          end
        end

        context "when the sync fails" do
          before do
            # rubocop: disable RSpec/AnyInstance
            allow_any_instance_of(Decidim::Centers::CreateOrUpdateScopeUser).to receive(:delete_existing_scope_user!).and_raise
            # rubocop: enable RSpec/AnyInstance
          end

          it "writes an error log" do
            expect(Rails.logger).to have_received(:error).with(/SyncScopeUserJob: ERROR/)
          end
        end
      end
    end
  end
end
