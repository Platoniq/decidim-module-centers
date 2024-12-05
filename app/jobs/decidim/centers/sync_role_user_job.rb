# frozen_string_literal: true

module Decidim
  module Centers
    class SyncRoleUserJob < ApplicationJob
      queue_as :default

      def perform(data)
        @user = Decidim::User.find(data[:user_id])
        @role = Decidim::Centers::Role.find(data[:role_id])
        create_or_update_role_user
      end

      private

      def create_or_update_role_user
        Decidim::Centers::CreateOrUpdateRoleUser.call(@role, @user) do
          on(:ok) do
            Rails.logger.info "SyncRoleUserJob: Success: updated for user #{@user.id}"
          end

          on(:invalid) do
            Rails.logger.error "SyncRoleUserJob: ERROR: not updated for user #{@user.id}"
          end
        end
      end
    end
  end
end
