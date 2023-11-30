# frozen_string_literal: true

module Decidim
  module Centers
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      #
      # Note that it inherits from `Decidim::Admin::ApplicationController`, which
      # override its layout and provide all kinds of useful methods.
      class ApplicationController < Decidim::Admin::ApplicationController
        register_permissions(::Decidim::Centers::Admin::ApplicationController,
                             ::Decidim::Centers::Admin::Permissions,
                             ::Decidim::Admin::Permissions)

        private

        def permission_class_chain
          ::Decidim.permissions_registry.chain_for(::Decidim::Centers::Admin::ApplicationController)
        end
      end
    end
  end
end
