# frozen_string_literal: true

module Rounds
  module Mailers
    class AppInvitation < Rounds::Mailer
      to { |user:| user[:email] }
      subject { |inviter:| "#{inviter[:name] || inviter[:email]} invited you to Rounds" }

      expose :inviter
      expose :url
    end
  end
end
