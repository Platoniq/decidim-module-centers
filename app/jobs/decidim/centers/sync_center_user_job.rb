# frozen_string_literal: true

module Decidim
  module Centers
    class SyncCenterUserJob < ApplicationJob
      queue_as :default

      def perform(data)
        @user = Decidim::User.find(data[:user_id])
        @center = Decidim::Centers::Center.find(data[:center_id])
        create_or_update_center_user
      end

      private

      def create_or_update_center_user
        Decidim::Centers::CreateOrUpdateCenterUser.call(@center, @user) do
          on(:ok) do
            Rails.logger.info "SyncCenterUserJob: Success: updated for user #{@user.id}"
          end

          on(:invalid) do
            Rails.logger.error "SyncCenterUserJob: ERROR: not updated for user #{@user.id}"
          end
        end
      end
    end
  end
end
