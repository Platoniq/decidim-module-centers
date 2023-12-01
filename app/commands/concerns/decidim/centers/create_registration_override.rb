# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Centers
    module CreateRegistrationOverride
      extend ActiveSupport::Concern

      include PublishCenterUpdateEvent

      def call
        if form.invalid?
          # :nocov:
          user = User.has_pending_invitations?(form.current_organization.id, form.email)
          user.invite!(user.invited_by) if user
          return broadcast(:invalid)
          # :nocov:
        end

        create_user
        publish_center_update_event

        broadcast(:ok, @user)
      rescue ActiveRecord::RecordInvalid
        # :nocov:
        broadcast(:invalid)
        # :nocov:
      end
    end
  end
end
