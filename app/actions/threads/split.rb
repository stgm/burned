# frozen_string_literal: true

module Rounds
  module Actions
    module Threads
      # Moves selected messages into a new thread.
      class Split < Rounds::Actions::ChatAction
        include Deps["chat.split_thread"]

        def handle(request, response)
          thread = load_thread(request, response, request.params[:id])
          result = split_thread.call(
            thread: thread, user: current_user(request),
            message_ids: request.params[:message_ids], title: request.params[:title]
          )

          case result
          in Success(new_thread)
            response.redirect_to "/threads/#{new_thread[:id]}"
          in Failure(_)
            response.flash[:alert] = "Select at least one message first."
            response.redirect_to "/threads/#{thread[:id]}"
          end
        end
      end
    end
  end
end
