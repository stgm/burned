# frozen_string_literal: true

module Rounds
  module Views
    module Updates
      # Renders only the parts of the page that change, for the page to swap in.
      class Show < Rounds::Views::Chat
        config.layout = false

        expose :messages
        expose :members, default: []
        expose :last_id, default: 0
      end
    end
  end
end
