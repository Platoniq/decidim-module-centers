# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Centers
    module UpdateAccountOverride
      extend ActiveSupport::Concern

      include PublishCenterUpdateEvent

      def call
        return broadcast(:invalid) unless @form.valid?

        update_personal_data
        update_avatar
        update_password

        if @user.valid?
          @user.save!
          notify_followers
          publish_center_update_event
          broadcast(:ok, @user.unconfirmed_email.present?)
        else
          [:avatar, :password, :password_confirmation].each do |key|
            @form.errors.add key, @user.errors[key] if @user.errors.has_key? key
          end
          broadcast(:invalid)
        end
      end
    end
  end
end
