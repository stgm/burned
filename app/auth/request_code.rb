# frozen_string_literal: true

require "securerandom"

module Rounds
  module Auth
    # Mails a six digit sign-in code to a known email address.
    # Always succeeds from the caller's point of view, so that nobody can find out who has an account.
    class RequestCode < Rounds::Operation
      include Deps[
        "repos.user_repo",
        "repos.login_code_repo",
        "mailers.login_code",
        "settings"
      ]

      CODE_LIFETIME = 10 * 60
      MIN_SECONDS_BETWEEN = 30

      def call(email)
        user = user_repo.find_by_email(email)
        return nil unless user

        latest = login_code_repo.latest(user[:id])
        return nil if latest && Time.now.utc - latest[:created_at] < MIN_SECONDS_BETWEEN

        code = format("%06d", SecureRandom.random_number(1_000_000))
        login_code_repo.replace(user[:id], self.class.digest(code, settings.session_secret), Time.now.utc + CODE_LIFETIME)
        login_code.deliver(user: user, code: code)
        nil
      end

      def self.digest(code, secret)
        OpenSSL::HMAC.hexdigest("SHA256", secret, code.to_s)
      end
    end
  end
end
