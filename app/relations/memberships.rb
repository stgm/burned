# frozen_string_literal: true

module Burned
  module Relations
    class Memberships < Burned::DB::Relation
      schema :memberships, infer: true
    end
  end
end
