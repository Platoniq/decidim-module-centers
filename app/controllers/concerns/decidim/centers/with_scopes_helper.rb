# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Centers
    module WithScopesHelper
      extend ActiveSupport::Concern

      included do
        helper Decidim::ScopesHelper
      end
    end
  end
end
