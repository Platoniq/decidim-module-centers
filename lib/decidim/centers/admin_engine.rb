# frozen_string_literal: true

module Decidim
  module Centers
    # This is the engine that runs on the public interface of `Centers`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Centers::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :centers
        resources :scopes, only: :index
        root to: "centers#index"
      end

      initializer "decidim_centers.admin_mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::Centers::AdminEngine, at: "/admin/centers", as: "decidim_admin_centers"
        end
      end

      initializer "decidim_centers.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.add_item :centers,
                        I18n.t("menu.centers", scope: "decidim.admin", default: "Centers"),
                        decidim_admin_centers.centers_path,
                        icon_name: "home",
                        position: 15,
                        active: :inclusive
        end
      end

      def load_seed
        nil
      end
    end
  end
end
