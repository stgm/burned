# frozen_string_literal: true

module Burned
  module Repos
    class TeamRepo < Burned::DB::Repo
      def find(id)
        db[:teams].where(id: id).first
      end

      # Lists the teams this person has joined, in the order they were joined.
      def for_user(user_id)
        db[:teams]
          .join(:memberships, team_id: :id)
          .where(Sequel[:memberships][:user_id] => user_id, Sequel[:memberships][:status] => "active")
          .order(Sequel[:memberships][:id])
          .select_all(:teams)
          .all
      end

      def create(name, creator_id)
        team_id = db[:teams].insert(name: name.strip, created_at: now, updated_at: now)
        db[:memberships].insert(
          team_id: team_id, user_id: creator_id, status: "active", admin: true,
          created_at: now, updated_at: now
        )
        find(team_id)
      end

      def membership(team_id, user_id)
        db[:memberships].where(team_id: team_id, user_id: user_id).first
      end

      def active_member?(team_id, user_id)
        db[:memberships].where(team_id: team_id, user_id: user_id, status: "active").count.positive?
      end

      def members(team_id, status: "active")
        db[:memberships]
          .join(:users, id: :user_id)
          .where(Sequel[:memberships][:team_id] => team_id, Sequel[:memberships][:status] => status)
          .order(Sequel[:users][:name], Sequel[:users][:email])
          .select(
            Sequel[:memberships][:id].as(:membership_id), Sequel[:memberships][:admin].as(:team_admin),
            Sequel[:users][:id], :name, :handle, :look, :email
          )
          .all
      end

      def invite(team_id, user_id, invited_by_id)
        return nil if membership(team_id, user_id)

        db[:memberships].insert(
          team_id: team_id, user_id: user_id, invited_by_id: invited_by_id, status: "invited",
          created_at: now, updated_at: now
        )
      end

      def invitations_for(user_id)
        db[:memberships]
          .join(:teams, id: :team_id)
          .left_join(Sequel[:users].as(:inviter), id: Sequel[:memberships][:invited_by_id])
          .where(Sequel[:memberships][:user_id] => user_id, Sequel[:memberships][:status] => "invited")
          .select(
            Sequel[:memberships][:id], Sequel[:memberships][:team_id], Sequel[:teams][:name],
            Sequel[:inviter][:name].as(:inviter_name), Sequel[:inviter][:email].as(:inviter_email)
          )
          .all
      end

      def find_invitation(id, user_id)
        db[:memberships].where(id: id, user_id: user_id, status: "invited").first
      end

      # Turns an invitation into a membership and starts tracking the team's existing threads.
      def accept(membership)
        db.transaction do
          db[:memberships].where(id: membership[:id]).update(status: "active", updated_at: now)
          db[:threads].where(team_id: membership[:team_id]).select(:id).each do |thread|
            last_id = db[:messages].where(thread_id: thread[:id]).max(:id) || 0
            db[:thread_states].insert(
              thread_id: thread[:id], user_id: membership[:user_id], level: "all", last_read_id: last_id
            )
          end
        end
      end

      def delete_membership(id)
        db[:memberships].where(id: id).delete
      end
    end
  end
end
