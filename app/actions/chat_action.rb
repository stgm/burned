# auto_register: false
# frozen_string_literal: true

module Burned
  module Actions
    # Base of every action that shows the chat frame: teams, thread list and recent threads.
    class ChatAction < Burned::Action
      include Deps["repos.team_repo", "repos.thread_repo"]

      before :load_frame

      private

      def load_frame(request, response)
        user = current_user(request)
        response[:current_user] = user
        response[:teams] = team_repo.for_user(user[:id])
        response[:bubbling] = thread_repo.bubbling_by_team(user[:id])
        response[:recent] = thread_repo.recent(user[:id])
        response[:invitation_count] = team_repo.invitations_for(user[:id]).size
      end

      # Reloads the lists and team markers, for after reading changed what is unread.
      def refresh_frame(request, response)
        user = current_user(request)
        response[:bubbling] = thread_repo.bubbling_by_team(user[:id])
        response[:recent] = thread_repo.recent(user[:id])
        team = response[:team]
        response[:team_threads] = thread_repo.list(team[:id], user[:id]) if team
      end

      # Finds a team that the current person belongs to, or stops with a 404.
      def load_team(request, response, id)
        team = team_repo.find(id.to_i)
        halt 404 unless team && team_repo.active_member?(team[:id], current_user(request)[:id])

        response[:team] = team
        response.session[:team_id] = team[:id]
        response[:team_threads] = thread_repo.list(team[:id], current_user(request)[:id])
        team
      end

      # Finds a thread in a team that the current person belongs to, or stops with a 404.
      def load_thread(request, response, id)
        thread = thread_repo.find(id.to_i)
        halt 404 unless thread

        load_team(request, response, thread[:team_id])
        response[:thread] = thread
        thread
      end
    end
  end
end
