# frozen_string_literal: true

module Burned
  module Actions
    module Profile
      class Edit < Burned::Action
        unnamed_allowed!

        def handle(request, response)
          response[:current_user] = current_user(request)
        end
      end
    end
  end
end
