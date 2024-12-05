# frozen_string_literal: true

module Decidim
  module Centers
    module Admin
      # This class holds a Form to update roles from Decidim's admin panel.
      class RoleForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String

        validates :title, translatable_presence: true

        alias organization current_organization
      end
    end
  end
end
