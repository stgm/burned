# frozen_string_literal: true

module Rounds
  module Relations
    class Memberships < Rounds::DB::Relation
      schema :memberships, infer: true
    end
  end
end
