# frozen_string_literal: true

module Rounds
  module Actions
    module Profile
      class Edit < Rounds::Action
        unnamed_allowed!

        def handle(request, response)
          response[:current_user] = current_user(request)
        end
      end
    end
  end
end
