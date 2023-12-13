# frozen_string_literal: true

module Decidim
  module Centers
    class SyncScopeUserJob < ApplicationJob
      queue_as :default

      def perform(data)
        @user = Decidim::User.find(data[:user_id])
        @scope = Decidim::Scope.find(data[:scope_id])
        create_or_update_scope_user
      end

      private

      def create_or_update_scope_user
        Decidim::Centers::CreateOrUpdateScopeUser.call(@scope, @user) do
          on(:ok) do
            Rails.logger.info "SyncScopeUserJob: Success: updated for user #{@user.id}"
          end

          on(:invalid) do
            Rails.logger.error "SyncScopeUserJob: ERROR: not updated for user #{@user.id}"
          end
        end
      end
    end
  end
end
