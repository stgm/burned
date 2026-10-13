# frozen_string_literal: true

module Burned
  module Actions
    module Sessions
      class Destroy < Burned::Action
        public_action!

        def handle(request, response)
          response.session[:user_id] = nil
          response.session[:team_id] = nil
          response.redirect_to "/login"
        end
      end
    end
  end
end
