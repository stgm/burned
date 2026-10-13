# frozen_string_literal: true

module Burned
  module Actions
    module People
      # Lists everyone who can sign in. Only app admins may use it.
      class Index < Burned::Actions::ChatAction
        def handle(request, response)
          halt 403 unless current_user(request)[:admin]

          response[:people] = user_repo.all
        end
      end
    end
  end
end
