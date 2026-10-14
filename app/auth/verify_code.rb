# frozen_string_literal: true

require "openssl"
require "rack/utils"

module Rounds
  module Auth
    # Checks a sign-in code and returns the person it belongs to.
    class VerifyCode < Rounds::Operation
      include Deps["repos.user_repo", "repos.login_code_repo", "settings"]

      MAX_ATTEMPTS = 5

      def call(email, code)
        user = user_repo.find_by_email(email)
        step Failure(:invalid) unless user

        stored = login_code_repo.latest(user[:id])
        step Failure(:invalid) unless stored
        step Failure(:expired) if stored[:expires_at] < Time.now.utc || stored[:attempts] >= MAX_ATTEMPTS

        login_code_repo.add_attempt(stored[:id])
        given = RequestCode.digest(code.to_s.gsub(/\s+/, ""), settings.session_secret)
        step Failure(:invalid) unless Rack::Utils.secure_compare(given, stored[:digest])

        login_code_repo.delete_for(user[:id])
        user
      end
    end
  end
end
