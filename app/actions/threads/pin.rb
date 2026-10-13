# frozen_string_literal: true

module Burned
  module Actions
    module Threads
      # Pins a thread to the top of the thread list for everyone in the team, or unpins it.
      class Pin < Burned::Actions::ChatAction
        def handle(request, response)
          thread = load_thread(request, response, request.params[:id])
          thread_repo.set_pinned(thread[:id], request.params[:pinned] == "1")
          response.redirect_to "/threads/#{thread[:id]}"
        end
      end
    end
  end
end
