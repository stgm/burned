# frozen_string_literal: true

module Burned
  module Relations
    class Mentions < Burned::DB::Relation
      schema :mentions, infer: true
    end
  end
end
