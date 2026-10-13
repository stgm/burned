# frozen_string_literal: true

module Burned
  module Mailers
    class LoginCode < Burned::Mailer
      to { |user:| user[:email] }
      subject { |code:| "#{code} is your Burned sign-in code" }

      expose :code
    end
  end
end
