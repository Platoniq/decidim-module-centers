# frozen_string_literal: true

module Decidim
  module Centers
    module Verifications
      class CenterActionAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
        def authorize
          return [:missing, { action: :authorize }] if authorization.blank?

          status_code = :unauthorized
          return [status_code, { fields: { centers: "..." } }] if authorization_centers.blank?
          return [:ok, {}] if options_centers.empty? || belongs_to_center?

          [status_code, {}]
        end

        private

        def options_centers
          options["centers"]&.split(",") || []
        end

        def authorization_centers
          authorization.metadata["centers"] || []
        end

        def belongs_to_center?
          options_centers.detect { |center| authorization_centers.include? center.to_i }
        end
      end
    end
  end
end
