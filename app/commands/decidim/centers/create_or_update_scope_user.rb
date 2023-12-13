# frozen_string_literal: true

module Decidim
  module Centers
    # This command is executed when a new relationship between user
    # and scope is created
    class CreateOrUpdateScopeUser < Decidim::Command
      # Initializes a CreateOrUpdateScopeUser Command.
      #
      # scope - The scope to be related with the user.
      # user - The user to be related with the scope.
      def initialize(scope, user)
        @scope = scope
        @user = user
      end

      # Creates or update the scope user if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        transaction do
          delete_existing_scope_user!
          create_scope_user!
        rescue ActiveRecord::RecordInvalid
          broadcast(:invalid)
        end

        broadcast(:ok, @scope_user)
      end

      private

      attr_reader :scope, :user

      def delete_existing_scope_user!
        ScopeUser.where(user: user).destroy_all
      end

      def create_scope_user!
        @scope_user = ScopeUser.create!(scope: scope, user: user)
      end
    end
  end
end
