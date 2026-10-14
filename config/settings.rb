# frozen_string_literal: true

module Rounds
  class Settings < Hanami::Settings
    # Signs the session cookie. Must be at least 64 characters.
    setting :session_secret, constructor: Types::String

    # Sender address of sign-in and invitation mails.
    setting :mail_from, default: "rounds@localhost", constructor: Types::String

    # Public address of the app, used in links inside mails.
    setting :app_url, default: "http://localhost:2300", constructor: Types::String

    # Name shown in mails and page titles.
    setting :app_name, default: "Rounds", constructor: Types::String
  end
end
