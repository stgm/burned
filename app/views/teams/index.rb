# frozen_string_literal: true

module Burned
  module Views
    module Teams
      class Index < Burned::Views::Chat
        expose :invitations
      end
    end
  end
end
