# frozen_string_literal: true

module Burned
  module Relations
    class ThreadStates < Burned::DB::Relation
      schema :thread_states, infer: true
    end
  end
end
