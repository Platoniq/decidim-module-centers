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

        has_many :center_roles, through: :role_users, source: :role

        has_many :scope_users,
                 class_name: "Decidim::Centers::ScopeUser",
                 foreign_key: "decidim_user_id",
                 dependent: :destroy

        has_many :scopes, through: :scope_users

        def center
          centers.first
        end

        def center_role
          center_roles.first
        end

        def scope
          scopes.first
        end
      end
    end
  end
end
