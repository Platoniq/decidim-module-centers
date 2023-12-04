# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Centers
    describe SyncCenterUserJob do
      subject { described_class }

      describe "queue" do
        it "is queued to events" do
          expect(subject.queue_name).to eq "default"
        end
      end

      describe "perform" do
        let(:user) { create :user }
        let(:center) { create :center }
        let(:params) { { user_id: user.id, center_id: center.id } }

        before do
          allow(Rails.logger).to receive(:info).and_call_original
          allow(Rails.logger).to receive(:error).and_call_original
          subject.perform_now(params)
        end

        context "when the sync runs successfully" do
          it "writes an info log" do
            expect(Rails.logger).to have_received(:info).with(/SyncCenterUserJob: Success/)
          end
        end

        context "when the sync fails" do
          before do
            # rubocop: disable RSpec/AnyInstance
            allow_any_instance_of(Decidim::Centers::CreateOrUpdateCenterUser).to receive(:delete_existing_center_user!).and_raise
            # rubocop: enable RSpec/AnyInstance
          end

          it "writes an error log" do
            expect(Rails.logger).to have_received(:error).with(/SyncCenterUserJob: ERROR/)
          end
        end
      end
    end
  end
end
