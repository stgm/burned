# auto_register: false
# frozen_string_literal: true

require "hanami/mailer"

module Rounds
  class Mailer < Hanami::Mailer
    from ENV.fetch("MAIL_FROM", "rounds@localhost")
  end
end
