# frozen_string_literal: true

module Rounds
  module Chat
    # Adds a message to a thread and records who it mentions.
    class PostMessage < Rounds::Operation
      include Deps["repos.team_repo", "repos.message_repo"]

      MAX_LENGTH = 5000

      def call(thread:, user:, body:)
        body = body.to_s.strip
        step Failure(:blank) if body.empty?
        step Failure(:too_long) if body.length > MAX_LENGTH

        members = team_repo.members(thread[:team_id])
        by_handle = members.to_h { |member| [member[:handle].to_s.downcase, member[:id]] }
        mentioned = Text.handles(body).filter_map { |handle| by_handle[handle] } - [user[:id]]

        message_repo.add(thread_id: thread[:id], user_id: user[:id], body: body, mentioned_ids: mentioned)
      end
    end
  end
end
