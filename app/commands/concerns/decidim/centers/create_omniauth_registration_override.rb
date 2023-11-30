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
            user = existing_identity.user
            verify_user_confirmed(user)

            return broadcast(:ok, user)
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
          broadcast(:error, e.record)
        end
      end
    end
  end
end
