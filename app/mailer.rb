# auto_register: false
# frozen_string_literal: true

require "hanami/mailer"

module Burned
  class Mailer < Hanami::Mailer
    from ENV.fetch("MAIL_FROM", "burned@localhost")
  end
end
