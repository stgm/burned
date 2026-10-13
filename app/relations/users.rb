# frozen_string_literal: true

module Burned
  module Relations
    class Users < Burned::DB::Relation
      schema :users, infer: true
    end
  end
end
