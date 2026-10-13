# frozen_string_literal: true

module Burned
  module Actions
    module Threads
      # Shows the thread list of a team. On a phone this is the whole screen.
      class Index < Burned::Actions::ChatAction
        def handle(request, response)
          load_team(request, response, request.params[:team_id])
        end
      end
    end
  end
end
