# frozen_string_literal: true

module Burned
  module Actions
    module Sessions
      # Signs a person in when their code is right.
      class Verify < Burned::Action
        public_action!
        include Deps["auth.verify_code"]

        def handle(request, response)
          email = request.session[:pending_email]
          return response.redirect_to("/login") unless email

          case verify_code.call(email, request.params[:code])
          in Success(user)
            response.session[:pending_email] = nil
            response.session[:user_id] = user[:id]
            response.redirect_to "/"
          in Failure(:expired)
            response.flash[:alert] = "That code has expired. Ask for a new one."
            response.redirect_to "/login"
          in Failure(_)
            response.flash[:alert] = "That code is not right."
            response.redirect_to "/login/code"
          end
        end
      end
    end
  end
end
