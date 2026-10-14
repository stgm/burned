# frozen_string_literal: true

module Rounds
  module Mailers
    class LoginCode < Rounds::Mailer
      to { |user:| user[:email] }
      subject { |code:| "#{code} is your Rounds sign-in code" }

      expose :code
    end
  end
end
