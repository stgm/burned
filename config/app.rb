# frozen_string_literal: true

require "hanami"
require "sequel"

# Stores and reads all times as UTC, on both SQLite and PostgreSQL.
Sequel.default_timezone = :utc

module Burned
  class App < Hanami::App
    # Keeps people signed in for three months, refreshed on every response.
    config.actions.sessions = :cookie, {
      key: "burned.session",
      secret: settings.session_secret,
      expire_after: 60 * 60 * 24 * 90,
      same_site: :lax,
      httponly: true,
      secure: Hanami.env?(:production)
    }
  end
end
