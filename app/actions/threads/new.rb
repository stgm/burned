# frozen_string_literal: true

module Burned
  module Actions
    module Threads
      class New < Burned::Actions::ChatAction
        def handle(request, response)
          load_team(request, response, request.params[:team_id])
        end
      end
    end
  end
end
