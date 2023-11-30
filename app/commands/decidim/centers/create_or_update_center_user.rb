# frozen_string_literal: true

module Decidim
  module Centers
    # This command is executed when a new relationship between user
    # and center is created
    class CreateOrUpdateCenterUser < Decidim::Command
      # Initializes a CreateOrUpdateCenterUser Command.
      #
      # center - The center to be related with the user.
      # user - The user to be related with the center.
      def initialize(center, user)
        @center = center
        @user = user
      end

      # Creates or update the center user if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        transaction do
          delete_existing_center_user!
          create_center_user!
        rescue ActiveRecord::RecordInvalid
          broadcast(:invalid)
        end

        broadcast(:ok, @center_user)
      end

      private

      attr_reader :center, :user

      def delete_existing_center_user!
        CenterUser.where(user: user).destroy_all
      end

      def create_center_user!
        @center_user = CenterUser.create!(center: center, user: user)
      end
    end
  end
end
