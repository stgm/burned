# frozen_string_literal: true

module Rounds
  module Relations
    class Messages < Rounds::DB::Relation
      schema :messages, infer: true
    end
  end
end
