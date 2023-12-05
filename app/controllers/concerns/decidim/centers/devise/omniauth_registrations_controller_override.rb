# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Centers
    module Devise
      module OmniauthRegistrationsControllerOverride
        extend ActiveSupport::Concern

        included do
          alias_method :original_first_login_and_not_authorized?, :first_login_and_not_authorized?

          def first_login_and_not_authorized?(user)
            original_first_login_and_not_authorized?(user) && Decidim::Verifications.workflows.any? { |manifest| manifest.name != "center" }
          end
        end
      end
    end
  end
end
