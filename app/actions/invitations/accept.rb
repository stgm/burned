# frozen_string_literal: true

module Rounds
  module Actions
    module Invitations
      class Accept < Rounds::Action
        include Deps["repos.team_repo"]

        def handle(request, response)
          membership = team_repo.find_invitation(request.params[:id].to_i, current_user(request)[:id])
          halt 404 unless membership

          team_repo.accept(membership)
          response.redirect_to "/teams/#{membership[:team_id]}"
        end
      end
    end
  end
end
