# frozen_string_literal: true

module Burned
  module Actions
    module Members
      # Invites a person to a team by email.
      class Create < Burned::Actions::ChatAction
        include Deps["chat.invite_to_team"]

        MESSAGES = {
          unknown_person: "That person has no account yet. Ask an admin to invite them to the app first.",
          invalid_email: "That does not look like an email address.",
          already_member: "That person is already in this team.",
          already_invited: "That person has already been invited."
        }.freeze

        def handle(request, response)
          team = load_team(request, response, request.params[:team_id])
          result = invite_to_team.call(team: team, inviter: current_user(request), email: request.params[:email])

          case result
          in Success(user)
            response.flash[:notice] = "Invited #{user[:email]}."
          in Failure(reason)
            response.flash[:alert] = MESSAGES.fetch(reason, "Could not invite that person.")
          end
          response.redirect_to "/teams/#{team[:id]}/members"
        end
      end
    end
  end
end
