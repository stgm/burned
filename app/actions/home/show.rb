# frozen_string_literal: true

module Burned
  module Actions
    module Home
      # Sends people to the most recent thread of the team they last used.
      class Show < Burned::Action
        include Deps["repos.team_repo", "repos.thread_repo"]

        def handle(request, response)
          teams = team_repo.for_user(current_user(request)[:id])
          team = teams.find { |t| t[:id] == request.session[:team_id] } || teams.first
          return response.redirect_to("/teams") unless team

          thread = thread_repo.latest_for_team(team[:id])
          response.redirect_to(thread ? "/threads/#{thread[:id]}" : "/teams/#{team[:id]}/threads")
        end
      end
    end
  end
end
