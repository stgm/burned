# frozen_string_literal: true

module Burned
  module Auth
    # Lets someone sign in by adding their email address, and mails them about it.
    class InviteToApp < Burned::Operation
      include Deps["repos.user_repo", "mailers.app_invitation", "settings"]

      EMAIL = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/

      def call(inviter:, email:)
        step Failure(:invalid_email) unless email.to_s.strip.match?(EMAIL)

        user, created = user_repo.invite(email)
        app_invitation.deliver(user: user, inviter: inviter, url: settings.app_url) if created
        user
      end
    end
  end
end
