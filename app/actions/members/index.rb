# frozen_string_literal: true

module Burned
  module Actions
    module Members
      class Index < Burned::Actions::ChatAction
        def handle(request, response)
          team = load_team(request, response, request.params[:team_id])
          response[:members] = team_repo.members(team[:id])
          response[:invited] = team_repo.members(team[:id], status: "invited")
        end
      end
    end
  end
end
