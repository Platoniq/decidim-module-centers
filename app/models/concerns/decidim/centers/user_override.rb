# frozen_string_literal: true

module Decidim
  module Centers
    module UserOverride
      extend ActiveSupport::Concern

      included do
        has_many :center_users,
                 class_name: "Decidim::Centers::CenterUser",
                 foreign_key: "decidim_user_id",
                 dependent: :destroy

        has_many :centers, through: :center_users

        has_many :role_users,
                 class_name: "Decidim::Centers::RoleUser",
                 foreign_key: "decidim_user_id",
                 dependent: :destroy

        has_many :roles, through: :role_users

        has_many :scope_users,
                 class_name: "Decidim::Centers::ScopeUser",
                 foreign_key: "decidim_user_id",
                 dependent: :destroy

        has_many :scopes, through: :scope_users

        def center
          centers.first
        end

        def role
          roles.first
        end

        def scope
          scopes.first
        end

        def valid?(context = nil)
          # @todo: Try to remove this hack and fix the root cause of the issue. When the user already has a role, the validation of the roles is failing
          super(context)
          errors.delete(:roles)
          errors.empty?
        end
      end
    end
  end
end
