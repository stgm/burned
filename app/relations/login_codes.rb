# frozen_string_literal: true

module Burned
  module Relations
    class LoginCodes < Burned::DB::Relation
      schema :login_codes, infer: true
    end
  end
end
