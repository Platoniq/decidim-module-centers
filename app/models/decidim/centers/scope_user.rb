# frozen_string_literal: true

module Decidim
  module Centers
    class ScopeUser < Centers::ApplicationRecord
      include UniqueByUser

      belongs_to :scope,
                 foreign_key: "decidim_scope_id",
                 class_name: "Decidim::Scope"

      belongs_to :user,
                 foreign_key: "decidim_user_id",
                 class_name: "Decidim::User"

      validate :same_organization

      private

      def same_organization
        return if scope.try(:organization) == user.try(:organization)

        errors.add(:scope, :invalid)
        errors.add(:user, :invalid)
      end
    end
  end
end
