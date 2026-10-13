# frozen_string_literal: true

module Burned
  module Repos
    class ThreadRepo < Burned::DB::Repo
      LEVELS = %w[all mentions never].freeze
      RECENT_LIMIT = 12

      def find(id)
        db[:threads].where(id: id).first
      end

      def latest_for_team(team_id)
        db[:threads].where(team_id: team_id).order(Sequel.desc(:last_message_at), Sequel.desc(:id)).first
      end

      def create(team_id:, user_id:, title:, source_thread_id: nil)
        db.transaction do
          thread_id = db[:threads].insert(
            team_id: team_id, created_by_id: user_id, title: title.strip,
            source_thread_id: source_thread_id, last_message_at: now, created_at: now
          )
          db[:memberships].where(team_id: team_id, status: "active").select_map(:user_id).each do |member_id|
            db[:thread_states].insert(thread_id: thread_id, user_id: member_id, level: "all", last_read_id: 0)
          end
          find(thread_id)
        end
      end

      def state(thread_id, user_id)
        db[:thread_states].where(thread_id: thread_id, user_id: user_id).first
      end

      def set_level(thread_id, user_id, level)
        return unless LEVELS.include?(level)

        db[:thread_states].where(thread_id: thread_id, user_id: user_id).update(level: level)
      end

      def mark_read(thread_id, user_id, message_id)
        db[:thread_states]
          .where(thread_id: thread_id, user_id: user_id)
          .where { last_read_id < message_id }
          .update(last_read_id: message_id)
      end

      # Pins a thread for everyone in the team, or removes the pin.
      def set_pinned(thread_id, pinned)
        db[:threads].where(id: thread_id).update(pinned_at: pinned ? now : nil)
      end

      # Lists a team's threads: pinned ones first in the order they were pinned, then this person's
      # bubble order: threads that bubble up, the rest by recent activity, and the threads they have quieted.
      def list(team_id, user_id)
        threads = db[:threads].where(team_id: team_id).order(Sequel.desc(:last_message_at), Sequel.desc(:id)).all
        threads = with_previews(with_activity(threads, user_id))
        threads.each_with_index.sort_by { |t, i| t[:pinned_at] ? [0, t[:pinned_at], 0] : [1, rank(t), i] }.map(&:first)
      end

      # Lists the threads this person took part in most recently, across all their teams.
      def recent(user_id)
        rows = db.fetch(<<~SQL, user_id, user_id).all
          SELECT t.id, t.team_id, t.title, t.last_message_at, tm.name AS team_name
          FROM messages m
          JOIN threads t ON t.id = m.thread_id
          JOIN teams tm ON tm.id = t.team_id
          JOIN memberships mb ON mb.team_id = t.team_id AND mb.user_id = ? AND mb.status = 'active'
          WHERE m.user_id = ?
          GROUP BY t.id, t.team_id, t.title, t.last_message_at, tm.name
          ORDER BY MAX(m.created_at) DESC
          LIMIT #{RECENT_LIMIT}
        SQL
        with_activity(rows, user_id)
      end

      # Returns, per team, how many threads are bubbling up for this person.
      def bubbling_by_team(user_id)
        rows = db[:thread_states]
          .join(:threads, id: :thread_id)
          .where(Sequel[:thread_states][:user_id] => user_id)
          .select(Sequel[:threads][:team_id], Sequel[:thread_states][:thread_id])
          .all
        activity = activity_for(user_id)
        rows.each_with_object(Hash.new(0)) do |row, counts|
          counts[row[:team_id]] += 1 if activity.dig(row[:thread_id], :bubbling)
        end
      end

      # Moves nothing, but prepares states for a thread built from messages of an older one.
      def seed_states_from(new_thread_id, old_thread_id, moved_max_id)
        db[:thread_states].where(thread_id: new_thread_id).each do |new_state|
          old = state(old_thread_id, new_state[:user_id])
          read_all = old && old[:last_read_id] >= moved_max_id
          db[:thread_states].where(id: new_state[:id]).update(
            last_read_id: read_all ? moved_max_id : 0,
            level: old ? old[:level] : "all"
          )
        end
      end

      def touch(thread_id, at)
        db[:threads].where(id: thread_id).update(last_message_at: at)
      end

      private

      def rank(thread)
        if thread[:bubbling] then 0
        elsif thread[:level] == "never" then 2
        else 1
        end
      end

      # Adds the latest message of each thread, for showing a snippet in lists.
      def with_previews(threads)
        return threads if threads.empty?

        latest = db[:messages].where(thread_id: threads.map { |t| t[:id] }).group(:thread_id)
          .select(:thread_id, Sequel.function(:max, :id).as(:max_id)).all.map { |r| r[:max_id] }
        previews = db[:messages].left_join(:users, id: :user_id).where(Sequel[:messages][:id] => latest)
          .select(Sequel[:messages][:thread_id], Sequel[:messages][:body], Sequel[:messages][:kind],
                  Sequel[:users][:name].as(:author_name)).all.to_h { |r| [r[:thread_id], r] }
        threads.map { |t| t.merge(preview: previews[t[:id]]) }
      end

      def with_activity(threads, user_id)
        activity = activity_for(user_id)
        threads.map { |t| t.merge(activity.fetch(t[:id]) { {level: "all", unread: 0, mentioned: 0, bubbling: false} }) }
      end

      # Counts unread and mentioning messages per thread for one person.
      def activity_for(user_id)
        rows = db.fetch(<<~SQL, user_id).all
          SELECT ts.thread_id, ts.level,
            (SELECT COUNT(*) FROM messages m
              WHERE m.thread_id = ts.thread_id AND m.id > ts.last_read_id
                AND (m.user_id IS NULL OR m.user_id <> ts.user_id)) AS unread,
            (SELECT COUNT(*) FROM mentions mn JOIN messages m ON m.id = mn.message_id
              WHERE m.thread_id = ts.thread_id AND m.id > ts.last_read_id
                AND mn.user_id = ts.user_id) AS mentioned
          FROM thread_states ts
          WHERE ts.user_id = ?
        SQL
        rows.to_h do |row|
          bubbling =
            case row[:level]
            when "all" then row[:unread].positive?
            when "mentions" then row[:mentioned].positive?
            else false
            end
          [row[:thread_id], {level: row[:level], unread: row[:unread], mentioned: row[:mentioned], bubbling: bubbling}]
        end
      end
    end
  end
end
