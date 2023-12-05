# frozen_string_literal: true

require "digest"

module Decidim
  module Centers
    module Verifications
      class Center < Decidim::AuthorizationHandler
        validate :center_present

        def metadata
          super.merge(
            centers: user.centers.pluck(:id)
          )
        end

        protected

        def center_present
          errors.add(:user, I18n.t("decidim.centers.authorizations.new.error")) unless user.centers.any?
        end
      end
    end
  end
end
