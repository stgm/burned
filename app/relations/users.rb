# frozen_string_literal: true

module Rounds
  module Relations
    class Users < Rounds::DB::Relation
      schema :users, infer: true
    end
  end
end
