# frozen_string_literal: true

module Burned
  module Views
    module Threads
      class Show < Burned::Views::Chat
        expose :messages
        expose :state
        expose :first_unread_id, default: nil
        expose :members
        expose :source, default: nil
      end
    end
  end
end
