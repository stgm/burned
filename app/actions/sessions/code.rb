# frozen_string_literal: true

module Burned
  module Actions
    module Sessions
      class Code < Burned::Action
        public_action!

        def handle(request, response)
          email = request.session[:pending_email]
          return response.redirect_to("/login") unless email

          response[:email] = email
        end
      end
    end
  end
end
