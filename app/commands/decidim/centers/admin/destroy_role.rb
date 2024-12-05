# frozen_string_literal: true

module Decidim
  module Centers
    module Admin
      # This command is executed when the user destroys a Role from the admin
      # panel.
      class DestroyRole < Decidim::Command
        # Initializes a DestroyRole Command.
        #
        # role - The current instance of the role to be destroyed.
        # current_user - The user who performs the action.
        def initialize(role, current_user)
          @role = role
          @current_user = current_user
        end

        # Destroys the role if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          transaction do
            destroy_role!
          end

          broadcast(:ok, role)
        end

        private

        attr_reader :role, :current_user

        def destroy_role!
          attributes = {
            deleted_at: Time.current
          }

          Decidim.traceability.update!(
            role,
            current_user,
            attributes
          )
        end
      end
    end
  end
end
