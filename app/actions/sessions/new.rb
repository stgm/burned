# frozen_string_literal: true

module Burned
  module Actions
    module Sessions
      class New < Burned::Action
        public_action!

        def handle(request, response)
          response.redirect_to "/" if user_repo.find(request.session[:user_id])
        end
      end
    end
  end
end
