# frozen_string_literal: true

require "digest"

module Decidim
  module Centers
    module Verifications
      class Center < Decidim::AuthorizationHandler
        validate :center_present
        validate :role_present
        validate :scope_present

        def metadata
          super.merge(
            centers: user.centers.pluck(:id),
            roles: user.center_roles.pluck(:id),
            scopes: user.scopes.pluck(:id)
          )
        end

        protected

        def center_present
          errors.add(:user, I18n.t("decidim.centers.authorizations.new.error")) unless user.centers.any?
        end

        def role_present
          return unless Decidim::Centers.roles_enabled

          errors.add(:user, I18n.t("decidim.centers.authorizations.new.error")) unless user.center_roles.any?
        end

        def scope_present
          return unless Decidim::Centers.scopes_enabled

          errors.add(:user, I18n.t("decidim.centers.authorizations.new.error")) unless user.scopes.any?
        end
      end
    end
  end
end
