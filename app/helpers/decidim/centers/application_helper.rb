# frozen_string_literal: true

module Decidim
  module Centers
    # Custom helpers, scoped to the centers engine.
    #
    module ApplicationHelper
      include TranslatableAttributes

      def center_options_for_select
        Decidim::Centers::Center.where(organization: current_organization).map do |center|
          [center.id, translated_attribute(center.title)]
        end
      end

      def role_options_for_select
        Decidim::Centers::Role.where(organization: current_organization).map do |role|
          [role.id, translated_attribute(role.title)]
        end
      end
    end
  end
end
