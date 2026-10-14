# frozen_string_literal: true

module Rounds
  module Views
    module Members
      class Index < Rounds::Views::Chat
        expose :members
        expose :invited
      end
    end
  end
end
