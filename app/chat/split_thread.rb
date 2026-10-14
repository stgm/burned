# frozen_string_literal: true

module Rounds
  module Chat
    # Moves selected messages into a new thread and leaves a link to it in the old thread.
    class SplitThread < Rounds::Operation
      include Deps["repos.thread_repo", "repos.message_repo"]

      def call(thread:, user:, message_ids:, title:)
        messages = message_repo.in_thread(thread[:id], Array(message_ids).map(&:to_i))
        step Failure(:no_messages) if messages.empty?

        title = title.to_s.strip
        title = messages.first[:body].lines.first.to_s.strip[0, 60] if title.empty?

        thread_repo.transaction do
          created = thread_repo.create(
            team_id: thread[:team_id], user_id: user[:id], title: title, source_thread_id: thread[:id]
          )
          moved_max = messages.map { |m| m[:id] }.max
          message_repo.move(messages.map { |m| m[:id] }, created[:id])
          thread_repo.touch(created[:id], messages.map { |m| m[:created_at] }.max)
          thread_repo.seed_states_from(created[:id], thread[:id], moved_max)
          message_repo.add(
            thread_id: thread[:id], user_id: user[:id], body: title, kind: "thread_link",
            linked_thread_id: created[:id]
          )
          created
        end
      end
    end
  end
end
