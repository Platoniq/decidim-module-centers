# frozen_string_literal: true

module Decidim
  module Centers
    module Admin
      # This class holds a Form to update centers from Decidim's admin panel.
      class CenterForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String

        validates :title, translatable_presence: true

        alias organization current_organization
      end
    end
  end
end
