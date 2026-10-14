# frozen_string_literal: true

module Rounds
  module Actions
    module Updates
      # Returns what changed since the page was loaded: new messages, bubbles and team markers.
      class Show < Rounds::Actions::ChatAction
        include Deps["repos.message_repo"]

        def handle(request, response)
          user = current_user(request)
          if request.params[:thread_id].to_s.empty?
            load_team(request, response, request.params[:team_id]) unless request.params[:team_id].to_s.empty?
            response[:messages] = []
          else
            thread = load_thread(request, response, request.params[:thread_id])
            messages = message_repo.list(thread[:id], after: request.params[:after].to_i)
            response[:messages] = messages
            response[:members] = team_repo.members(thread[:team_id])
            if request.params[:read] == "1" && messages.any?
              thread_repo.mark_read(thread[:id], user[:id], messages.last[:id])
            end
            response[:last_id] = messages.last&.fetch(:id) || request.params[:after].to_i
          end
          refresh_frame(request, response)
          response.headers["Cache-Control"] = "no-store"
        end
      end
    end
  end
end
