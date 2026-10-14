# frozen_string_literal: true

module Rounds
  module Views
    module Threads
      class Index < Rounds::Views::Chat
        # On a phone the list takes the whole screen.
        expose :pane, layout: true do
          "list"
        end
      end
    end
  end
end
