# frozen_string_literal: true

module Burned
  module Actions
    module People
      # Lets an app admin invite someone by email.
      class Create < Burned::Actions::ChatAction
        include Deps["auth.invite_to_app"]

        def handle(request, response)
          inviter = current_user(request)
          halt 403 unless inviter[:admin]

          case invite_to_app.call(inviter: inviter, email: request.params[:email])
          in Success(user)
            response.flash[:notice] = "Invited #{user[:email]}."
          in Failure(_)
            response.flash[:alert] = "That does not look like an email address."
          end
          response.redirect_to "/people"
        end
      end
    end
  end
end
