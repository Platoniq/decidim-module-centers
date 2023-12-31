# frozen_string_literal: true

module Decidim
  module Centers
    class CenterUser < Centers::ApplicationRecord
      include UniqueByUser

      belongs_to :center,
                 foreign_key: "decidim_centers_center_id",
                 class_name: "Decidim::Centers::Center"

      belongs_to :user,
                 foreign_key: "decidim_user_id",
                 class_name: "Decidim::User"

      validate :same_organization

      private

      def same_organization
        return if center.try(:organization) == user.try(:organization)

        errors.add(:center, :invalid)
        errors.add(:user, :invalid)
      end
    end
  end
end
