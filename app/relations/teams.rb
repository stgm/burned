# frozen_string_literal: true

module Burned
  module Relations
    class Teams < Burned::DB::Relation
      schema :teams, infer: true
    end
  end
end
