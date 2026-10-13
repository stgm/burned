# frozen_string_literal: true

module Burned
  module Actions
    module Threads
      # Changes when a thread bubbles up for the current person.
      class Quiet < Burned::Actions::ChatAction
        def handle(request, response)
          thread = load_thread(request, response, request.params[:id])
          thread_repo.set_level(thread[:id], current_user(request)[:id], request.params[:level].to_s)
          response.redirect_to "/threads/#{thread[:id]}"
        end
      end
    end
  end
end
