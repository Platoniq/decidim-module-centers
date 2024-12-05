# frozen_string_literal: true

module Decidim
  module Centers
    class RoleUser < Centers::ApplicationRecord
      include UniqueByUser

      belongs_to :role,
                 foreign_key: "decidim_centers_role_id",
                 class_name: "Decidim::Centers::Role"

      belongs_to :user,
                 foreign_key: "decidim_user_id",
                 class_name: "Decidim::User"

      validate :same_organization

      private

      def same_organization
        return if role.try(:organization) == user.try(:organization)

        errors.add(:role, :invalid)
        errors.add(:user, :invalid)
      end
    end
  end
end
