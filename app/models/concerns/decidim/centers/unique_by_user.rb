# frozen_string_literal: true

module Decidim
  module Centers
    module UniqueByUser
      extend ActiveSupport::Concern

      included do
        validate :unique_by_user

        def unique_by_user
          return if self.class.where(user: user).empty?

          errors.add(:user, :invalid)
        end
      end
    end
  end
end
