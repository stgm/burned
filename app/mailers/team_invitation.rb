# frozen_string_literal: true

module Burned
  module Mailers
    class TeamInvitation < Burned::Mailer
      to { |user:| user[:email] }
      subject { |team:| "You are invited to join #{team[:name]} on Burned" }

      expose :team
      expose :inviter
      expose :url
    end
  end
end
