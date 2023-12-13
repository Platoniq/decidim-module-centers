# frozen_string_literal: true

module Decidim
  module Centers
    class AutoVerificationJob < ApplicationJob
      queue_as :default

      def perform(user_id)
        @user = Decidim::User.find(user_id)
        @user.centers.any? || @user.scopes.any? ? create_auth : remove_auth
      rescue ActiveRecord::RecordNotFound => _e
        Rails.logger.error "AutoVerificationJob: ERROR: user not found #{user_id}"
      end

      private

      def create_auth
        return unless (handler = Decidim::AuthorizationHandler.handler_for("center", user: @user))

        Decidim::Verifications::AuthorizeUser.call(handler, @user.organization) do
          on(:ok) do
            Rails.logger.info "AutoVerificationJob: Success: created for user #{handler.user.id}"
          end

          on(:invalid) do
            Rails.logger.error "AutoVerificationJob: ERROR: not created for user #{handler.user&.id}"
          end
        end
      end

      def remove_auth
        Decidim::Authorization.where(user: @user, name: "center").each do |auth|
          Decidim::Verifications::DestroyUserAuthorization.call(auth) do
            on(:ok) do
              Rails.logger.info "AutoVerificationJob: Success: removed for user #{auth.user.id}"
            end

            on(:invalid) do
              Rails.logger.error "AutoVerificationJob: ERROR: not removed for user #{auth.user&.id}"
            end
          end
        end
      end
    end
  end
end
