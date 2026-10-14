# frozen_string_literal: true

module Rounds
  module Relations
    class ThreadStates < Rounds::DB::Relation
      schema :thread_states, infer: true
    end
  end
end
