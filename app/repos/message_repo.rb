# frozen_string_literal: true

module Burned
  module Repos
    class MessageRepo < Burned::DB::Repo
      PAGE = 200

      def find(id)
        db[:messages].where(id: id).first
      end

      # Lists a thread's messages with their authors, oldest first.
      def list(thread_id, after: nil)
        scope = authored.where(Sequel[:messages][:thread_id] => thread_id)
        if after
          scope.where { Sequel[:messages][:id] > after }.order(Sequel[:messages][:id]).all
        else
          scope.order(Sequel.desc(Sequel[:messages][:id])).limit(PAGE).all.reverse
        end
      end

      def add(thread_id:, user_id:, body:, mentioned_ids: [], kind: "text", linked_thread_id: nil)
        db.transaction do
          at = now
          id = db[:messages].insert(
            thread_id: thread_id, user_id: user_id, body: body, kind: kind,
            linked_thread_id: linked_thread_id, created_at: at
          )
          mentioned_ids.uniq.each { |uid| db[:mentions].insert(message_id: id, user_id: uid) }
          db[:threads].where(id: thread_id).update(last_message_at: at)
          db[:thread_states]
            .where(thread_id: thread_id, user_id: user_id)
            .where { last_read_id < id }
            .update(last_read_id: id)
          id
        end
      end

      def in_thread(thread_id, ids)
        db[:messages].where(thread_id: thread_id, id: ids, kind: "text").order(:id).all
      end

      def move(ids, to_thread_id)
        db[:messages].where(id: ids).update(thread_id: to_thread_id)
      end

      def latest_id(thread_id)
        db[:messages].where(thread_id: thread_id).max(:id) || 0
      end

      private

      def authored
        db[:messages]
          .left_join(:users, id: :user_id)
          .left_join(Sequel[:threads].as(:linked), id: Sequel[:messages][:linked_thread_id])
          .select(
            Sequel[:messages][:id], Sequel[:messages][:thread_id], Sequel[:messages][:user_id],
            Sequel[:messages][:kind], Sequel[:messages][:body], Sequel[:messages][:created_at],
            Sequel[:messages][:linked_thread_id], Sequel[:linked][:title].as(:linked_title),
            Sequel[:users][:name].as(:author_name), Sequel[:users][:handle].as(:author_handle),
            Sequel[:users][:look].as(:author_look), Sequel[:users][:email].as(:author_email)
          )
      end
    end
  end
end
