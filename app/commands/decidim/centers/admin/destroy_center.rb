# frozen_string_literal: true

module Decidim
  module Centers
    module Admin
      # This command is executed when the user destroys a Center from the admin
      # panel.
      class DestroyCenter < Decidim::Command
        # Initializes a DestroyCenter Command.
        #
        # center - The current instance of the center to be destroyed.
        # current_user - The user who performs the action.
        def initialize(center, current_user)
          @center = center
          @current_user = current_user
        end

        # Destroys the center if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          transaction do
            destroy_center!
          end

          broadcast(:ok, center)
        end

        private

        attr_reader :center, :current_user

        def destroy_center!
          attributes = {
            deleted_at: Time.current
          }

          Decidim.traceability.update!(
            center,
            current_user,
            attributes
          )
        end
      end
    end
  end
end
