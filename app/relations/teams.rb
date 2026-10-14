# frozen_string_literal: true

module Rounds
  module Relations
    class Teams < Rounds::DB::Relation
      schema :teams, infer: true
    end
  end
end
