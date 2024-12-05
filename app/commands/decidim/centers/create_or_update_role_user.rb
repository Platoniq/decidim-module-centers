# frozen_string_literal: true

module Decidim
  module Centers
    # This command is executed when a new relationship between user
    # and role is created
    class CreateOrUpdateRoleUser < Decidim::Command
      # Initializes a CreateOrUpdateRoleUser Command.
      #
      # role - The role to be related with the user.
      # user - The user to be related with the role.
      def initialize(role, user)
        @role = role
        @user = user
      end

      # Creates or update the role user if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        transaction do
          delete_existing_role_user!
          create_role_user!
        rescue ActiveRecord::RecordInvalid
          broadcast(:invalid)
        end

        broadcast(:ok, @role_user)
      end

      private

      attr_reader :role, :user

      def delete_existing_role_user!
        RoleUser.where(user: user).destroy_all
      end

      def create_role_user!
        @role_user = RoleUser.create!(role: role, user: user)
      end
    end
  end
end
