# frozen_string_literal: true

module Burned
  module Actions
    module Teams
      class Create < Burned::Actions::ChatAction
        def handle(request, response)
          name = request.params[:name].to_s.strip
          if name.empty? || name.length > 60
            response.flash[:alert] = "Enter a team name of up to 60 characters."
            return response.redirect_to("/teams")
          end

          team = team_repo.create(name, current_user(request)[:id])
          response.redirect_to "/teams/#{team[:id]}/threads"
        end
      end
    end
  end
end
