# frozen_string_literal: true

module Burned
  module Actions
    module Threads
      class Show < Burned::Actions::ChatAction
        include Deps["repos.message_repo"]

        def handle(request, response)
          user = current_user(request)
          thread = load_thread(request, response, request.params[:id])
          state = thread_repo.state(thread[:id], user[:id])
          messages = message_repo.list(thread[:id])

          response[:messages] = messages
          response[:state] = state
          response[:first_unread_id] =
            messages.find { |m| m[:id] > state[:last_read_id] && m[:user_id] != user[:id] }&.fetch(:id)
          response[:members] = team_repo.members(thread[:team_id])
          response[:source] = thread[:source_thread_id] && thread_repo.find(thread[:source_thread_id])

          thread_repo.mark_read(thread[:id], user[:id], messages.last[:id]) if messages.any?
          refresh_frame(request, response)
        end
      end
    end
  end
end
