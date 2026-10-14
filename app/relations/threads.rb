# frozen_string_literal: true

module Rounds
  module Relations
    class Threads < Rounds::DB::Relation
      schema :threads, infer: true
    end
  end
end
