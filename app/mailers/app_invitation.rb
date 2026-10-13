# frozen_string_literal: true

module Burned
  module Mailers
    class AppInvitation < Burned::Mailer
      to { |user:| user[:email] }
      subject { |inviter:| "#{inviter[:name] || inviter[:email]} invited you to Burned" }

      expose :inviter
      expose :url
    end
  end
end
