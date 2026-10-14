# frozen_string_literal: true

module Rounds
  module Relations
    class LoginCodes < Rounds::DB::Relation
      schema :login_codes, infer: true
    end
  end
end
