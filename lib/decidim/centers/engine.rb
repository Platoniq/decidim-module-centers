# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Centers
    # This is the engine that runs on the public interface of centers.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Centers

      routes do
        # Add engine routes here
        # resources :centers
        # root to: "centers#index"
      end

      config.to_prepare do
        Decidim::User.include(Decidim::Centers::UserOverride)
      end

      initializer "Centers.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
