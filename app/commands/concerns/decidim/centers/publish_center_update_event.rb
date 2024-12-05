# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Centers
    module PublishCenterUpdateEvent
      extend ActiveSupport::Concern

      def publish_center_update_event
        ActiveSupport::Notifications.publish(
          "decidim.centers.user.updated",
          user_id: @user.id,
          center_id: @form.center_id,
          role_id: @form.role_id,
          scope_id: @form.scope_id
        )
      end
    end
  end
end
