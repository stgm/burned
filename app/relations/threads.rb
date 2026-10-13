# frozen_string_literal: true

module Burned
  module Relations
    class Threads < Burned::DB::Relation
      schema :threads, infer: true
    end
  end
end
