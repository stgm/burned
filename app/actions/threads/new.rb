# frozen_string_literal: true

module Rounds
  module Actions
    module Threads
      class New < Rounds::Actions::ChatAction
        def handle(request, response)
          load_team(request, response, request.params[:team_id])
        end
      end
    end
  end
end
