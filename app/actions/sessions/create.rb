# frozen_string_literal: true

module Rounds
  module Actions
    module Sessions
      # Mails a sign-in code and asks for it on the next page.
      class Create < Rounds::Action
        public_action!
        include Deps["auth.request_code"]

        def handle(request, response)
          email = request.params[:email].to_s.strip.downcase
          if email.empty?
            response.flash[:alert] = "Enter your email address."
            return response.redirect_to("/login")
          end

          request_code.call(email)
          response.session[:pending_email] = email
          response.redirect_to "/login/code"
        end
      end
    end
  end
end
