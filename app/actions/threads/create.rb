# frozen_string_literal: true

module Rounds
  module Actions
    module Threads
      class Create < Rounds::Actions::ChatAction
        include Deps["chat.post_message"]

        def handle(request, response)
          user = current_user(request)
          team = load_team(request, response, request.params[:team_id])
          title = request.params[:title].to_s.strip
          if title.empty? || title.length > 100
            response.flash[:alert] = "Give the thread a title of up to 100 characters."
            return response.redirect_to("/teams/#{team[:id]}/threads/new")
          end

          thread = thread_repo.create(team_id: team[:id], user_id: user[:id], title: title)
          first = request.params[:body].to_s.strip
          post_message.call(thread: thread, user: user, body: first) unless first.empty?
          response.redirect_to "/threads/#{thread[:id]}"
        end
      end
    end
  end
end
