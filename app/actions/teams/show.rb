# frozen_string_literal: true

module Rounds
  module Actions
    module Teams
      # Opens the most recent thread of a team.
      class Show < Rounds::Actions::ChatAction
        def handle(request, response)
          team = load_team(request, response, request.params[:id])
          thread = thread_repo.latest_for_team(team[:id])
          response.redirect_to(thread ? "/threads/#{thread[:id]}" : "/teams/#{team[:id]}/threads")
        end
      end
    end
  end
end
