# frozen_string_literal: true

module Decidim
  module Centers
    module Admin
      # This command is executed when the user creates a Role from the admin
      # panel.
      class CreateRole < Decidim::Command
        # Initializes a CreateRole Command.
        #
        # form - The form from which to get the data.
        # current_user - The user who performs the action.
        def initialize(form, current_user)
          @form = form
          @current_user = current_user
        end

        # Creates the role if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            create_role!
          end

          broadcast(:ok, @role)
        end

        private

        attr_reader :form, :current_user

        def create_role!
          attributes = {
            organization: form.current_organization,
            title: form.title
          }

          @role = Decidim.traceability.create!(
            Role,
            current_user,
            attributes
          )
        end
      end
    end
  end
end
