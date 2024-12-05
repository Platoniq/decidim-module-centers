# frozen_string_literal: true

module Decidim
  module Centers
    module AdminLog
      # This class holds the logic to present a `Decidim::Centers::Role`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    RolePresenter.new(action_log, view_helpers).present
      class RolePresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "create", "delete", "update"
            "decidim.centers.admin_log.role.#{action}"
          else
            super
          end
        end
      end
    end
  end
end
