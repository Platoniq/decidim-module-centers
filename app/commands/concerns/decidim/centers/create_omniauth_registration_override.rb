# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Centers
    module CreateOmniauthRegistrationOverride
      extend ActiveSupport::Concern

      include PublishCenterUpdateEvent

      def call
        verify_oauth_signature!

        begin
          if existing_identity
            # :nocov:
            user = existing_identity.user
            verify_user_confirmed(user)

            return broadcast(:ok, user)
            # :nocov:
          end
          return broadcast(:invalid) if form.invalid?

          transaction do
            create_or_find_user
            @identity = create_identity
          end
          trigger_omniauth_registration
          publish_center_update_event

          broadcast(:ok, @user)
        rescue ActiveRecord::RecordInvalid => e
          # :nocov:
          broadcast(:error, e.record)
          # :nocov:
        end
      end
    end
  end
end
