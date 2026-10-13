# frozen_string_literal: true

module Burned
  module Actions
    module Teams
      class Index < Burned::Actions::ChatAction
        def handle(request, response)
          response[:invitations] = team_repo.invitations_for(current_user(request)[:id])
        end
      end
    end
  end
end
