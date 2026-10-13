# frozen_string_literal: true

module Burned
  module Relations
    class Messages < Burned::DB::Relation
      schema :messages, infer: true
    end
  end
end
