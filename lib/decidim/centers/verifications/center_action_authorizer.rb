# frozen_string_literal: true

module Decidim
  module Centers
    module Verifications
      class CenterActionAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
        def authorize
          return [:missing, { action: :authorize }] if authorization.blank?

          status_code = :unauthorized
          return [status_code, { fields: { centers: "..." } }] if authorization_centers.blank?
          return [:ok, {}] if belongs_to_center? && belongs_to_scope?

          [status_code, {}]
        end

        private

        def options_centers
          options["centers"]&.split(",") || []
        end

        def options_scopes
          return [] unless Decidim::Centers.scopes_enabled

          options["scopes"]&.split(",") || []
        end

        def authorization_centers
          authorization.metadata["centers"] || []
        end

        def authorization_scopes
          authorization.metadata["scopes"] || []
        end

        def belongs_to_center?
          options_centers.empty? || options_centers.detect { |center| authorization_centers.include? center.to_i }
        end

        def belongs_to_scope?
          return true unless Decidim::Centers.scopes_enabled

          options_scopes.empty? || options_scopes.detect { |scope| authorization_scopes.include? scope.to_i }
        end
      end
    end
  end
end
