# frozen_string_literal: true

module Burned
  module Actions
    module Invitations
      class Decline < Burned::Action
        include Deps["repos.team_repo"]

        def handle(request, response)
          membership = team_repo.find_invitation(request.params[:id].to_i, current_user(request)[:id])
          halt 404 unless membership

          team_repo.delete_membership(membership[:id])
          response.redirect_to "/teams"
        end
      end
    end
  end
end
