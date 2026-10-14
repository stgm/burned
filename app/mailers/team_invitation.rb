# frozen_string_literal: true

module Rounds
  module Mailers
    class TeamInvitation < Rounds::Mailer
      to { |user:| user[:email] }
      subject { |team:| "You are invited to join #{team[:name]} on Rounds" }

      expose :team
      expose :inviter
      expose :url
    end
  end
end
