# frozen_string_literal: true

module Burned
  module Actions
    module Messages
      class Create < Burned::Actions::ChatAction
        include Deps["chat.post_message"]

        def handle(request, response)
          thread = load_thread(request, response, request.params[:id])
          result = post_message.call(thread: thread, user: current_user(request), body: request.params[:body])

          if ajax?(request)
            response.status = result.success? ? 204 : 422
          else
            response.redirect_to "/threads/#{thread[:id]}"
          end
        end
      end
    end
  end
end
