# frozen_string_literal: true

module Rounds
  module Views
    module Threads
      class Show < Rounds::Views::Chat
        expose :messages
        expose :state
        expose :first_unread_id, default: nil
        expose :members
        expose :source, default: nil
      end
    end
  end
end
