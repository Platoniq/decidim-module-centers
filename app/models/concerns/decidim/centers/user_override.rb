# frozen_string_literal: true

module Decidim
  module Centers
    module UserOverride
      extend ActiveSupport::Concern

      included do
        has_many :center_users,
                 class_name: "Decidim::Centers::CenterUser",
                 foreign_key: "decidim_user_id",
                 dependent: :destroy

        has_many :centers, through: :center_users

        def center
          centers.first
        end
      end
    end
  end
end
