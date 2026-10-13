# auto_register: false
# frozen_string_literal: true

module Burned
  module Views
    # Base of every view that shows the chat frame. The layout needs these exposures too.
    class Chat < Burned::View
      config.layout = "chat"

      expose :current_user, layout: true
      expose :teams, layout: true
      expose :bubbling, layout: true
      expose :invitation_count, layout: true
      expose :team, default: nil, layout: true
      expose :recent, default: [], layout: true
      expose :team_threads, default: [], layout: true
      expose :pane, default: "detail", layout: true
      expose :thread, default: nil, layout: true
    end
  end
end
