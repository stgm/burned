# frozen_string_literal: true

module Rounds
  module Relations
    class Mentions < Rounds::DB::Relation
      schema :mentions, infer: true
    end
  end
end
