# frozen_string_literal: true

module Burned
  module Actions
    module Profile
      class Update < Burned::Action
        unnamed_allowed!

        def handle(request, response)
          name = request.params[:name].to_s.strip
          if name.empty? || name.length > 60
            response.flash[:alert] = "Enter a name of up to 60 characters."
            return response.redirect_to("/welcome")
          end

          user_repo.set_name(current_user(request)[:id], name)
          response.redirect_to "/"
        end
      end
    end
  end
end
