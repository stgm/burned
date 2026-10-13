# frozen_string_literal: true

module Burned
  module Views
    module Members
      class Index < Burned::Views::Chat
        expose :members
        expose :invited
      end
    end
  end
end
