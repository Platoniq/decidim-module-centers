# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Centers
    module AccountFormOverride
      extend ActiveSupport::Concern

      included do
        alias_method :original_map_model, :map_model

        include Decidim::Centers::ApplicationHelper

        attribute :center_id, Integer
        attribute :role_id, Integer
        attribute :scope_id, Integer

        validates :center_id, presence: true
        validates :role_id, presence: true, if: :role_id?
        validates :scope_id, presence: true, if: :scope_id?

        def map_model(model)
          original_map_model(model)

          self.center_id = model.center.try(:id)
          self.role_id = model.role.try(:id)
          self.scope_id = model.scope.try(:id)
        end

        private

        def role_id?
          Decidim::Centers.roles_enabled
        end

        def scope_id?
          Decidim::Centers.scopes_enabled
        end
      end
    end
  end
end
