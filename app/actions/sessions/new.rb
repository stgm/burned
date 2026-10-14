# frozen_string_literal: true

module Rounds
  module Actions
    module Sessions
      class New < Rounds::Action
        public_action!

        def handle(request, response)
          response.redirect_to "/" if user_repo.find(request.session[:user_id])
        end
      end
    end
  end
end
