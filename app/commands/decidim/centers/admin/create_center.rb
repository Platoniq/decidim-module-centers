# frozen_string_literal: true

module Decidim
  module Centers
    module Admin
      # This command is executed when the user creates a Center from the admin
      # panel.
      class CreateCenter < Decidim::Command
        # Initializes a CreateCenter Command.
        #
        # form - The form from which to get the data.
        # current_user - The user who performs the action.
        def initialize(form, current_user)
          @form = form
          @current_user = current_user
        end

        # Creates the center if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            create_center!
          end

          broadcast(:ok, @center)
        end

        private

        attr_reader :form, :current_user

        def create_center!
          attributes = {
            organization: form.current_organization,
            title: form.title
          }

          @center = Decidim.traceability.create!(
            Center,
            current_user,
            attributes
          )
        end
      end
    end
  end
end
