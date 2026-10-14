# frozen_string_literal: true

require "hanami/mailer"

module Rounds
  # Writes each mail to the logger and to log/mail.log instead of sending it.
  class LogDelivery < Hanami::Mailer::Delivery::Test
    def initialize(logger, file: Hanami.app.root.join("log", "mail.log"))
      super()
      @logger = logger
      @file = file
    end

    def call(message)
      text = "MAIL to #{message.to.join(", ")}\nSubject: #{message.subject}\n\n#{message.text_body}"
      @logger.info(text)
      @file.dirname.mkpath
      @file.open("a") { |f| f.puts("#{Time.now.utc.iso8601} #{text}\n---") }
      super
    end
  end
end
