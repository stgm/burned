# frozen_string_literal: true

module Rounds
  module Chat
    # Invites a person to a team. App admins can also bring in people who do not have an account yet.
    class InviteToTeam < Rounds::Operation
      include Deps[
        "repos.user_repo",
        "repos.team_repo",
        "mailers.team_invitation",
        "auth.invite_to_app",
        "settings"
      ]

      def call(team:, inviter:, email:)
        user = user_repo.find_by_email(email)
        if user.nil?
          step Failure(:unknown_person) unless inviter[:admin]
          user = step invite_to_app.call(inviter: inviter, email: email)
        end

        membership = team_repo.membership(team[:id], user[:id])
        step Failure(:already_member) if membership && membership[:status] == "active"
        step Failure(:already_invited) if membership

        team_repo.invite(team[:id], user[:id], inviter[:id])
        team_invitation.deliver(user: user, team: team, inviter: inviter, url: settings.app_url)
        user
      end
    end
  end
end
