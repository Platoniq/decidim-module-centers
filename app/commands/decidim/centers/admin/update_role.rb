# frozen_string_literal: true

module Decidim
  module Centers
    module Admin
      # This command is executed when the user changes a Role from the admin
      # panel.
      class UpdateRole < Decidim::Command
        # Initializes a UpdateRole Command.
        #
        # form - The form from which to get the data.
        # role - The current instance of the role to be updated.
        # current_user - The user who performs the action.
        def initialize(form, role, current_user)
          @form = form
          @role = role
          @current_user = current_user
        end

        # Updates the role if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            update_role!
          end

          broadcast(:ok, role)
        end

        private

        attr_reader :form, :role, :current_user

        def update_role!
          Decidim.traceability.update!(
            role,
            current_user,
            title: form.title
          )
        end
      end
    end
  end
end
