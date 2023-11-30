# frozen_string_literal: true

module Decidim
  module Centers
    # This is the engine that runs on the public interface of `Centers`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Centers::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        # resources :centers do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "centers#index"
      end

      def load_seed
        nil
      end
    end
  end
end
