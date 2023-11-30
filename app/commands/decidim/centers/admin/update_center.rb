# frozen_string_literal: true

module Decidim
  module Centers
    module Admin
      # This command is executed when the user changes a Center from the admin
      # panel.
      class UpdateCenter < Decidim::Command
        # Initializes a UpdateCenter Command.
        #
        # form - The form from which to get the data.
        # center - The current instance of the center to be updated.
        # current_user - The user who performs the action.
        def initialize(form, center, current_user)
          @form = form
          @center = center
          @current_user = current_user
        end

        # Updates the center if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            update_center!
          end

          broadcast(:ok, center)
        end

        private

        attr_reader :form, :center, :current_user

        def update_center!
          Decidim.traceability.update!(
            center,
            current_user,
            title: form.title
          )
        end
      end
    end
  end
end
