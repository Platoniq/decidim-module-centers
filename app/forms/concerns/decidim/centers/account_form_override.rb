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

        validates :center_id, presence: true

        def map_model(model)
          original_map_model(model)

          self.center_id = model.center.try(:id)
        end
      end
    end
  end
end
