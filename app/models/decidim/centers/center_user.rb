# frozen_string_literal: true

module Decidim
  module Centers
    class CenterUser < Centers::ApplicationRecord
      belongs_to :center,
                 foreign_key: "decidim_centers_center_id",
                 class_name: "Decidim::Centers::Center"

      belongs_to :user,
                 foreign_key: "decidim_user_id",
                 class_name: "Decidim::User"

      has_many :center_users,
               class_name: "Decidim::Centers::CenterUser",
               foreign_key: "decidim_centers_center_id",
               dependent: :destroy

      validate :same_organization
      validate :unique_center_by_user

      private

      def same_organization
        return if center.try(:organization) == user.try(:organization)

        errors.add(:center, :invalid)
        errors.add(:user, :invalid)
      end

      def unique_center_by_user
        return if self.class.where(user: user).empty?

        errors.add(:user, :invalid)
      end
    end
  end
end
