# frozen_string_literal: true

# Prints mail to the log in development when no SMTP server is configured, so sign-in codes
# can be read from the server output. Other environments use Hanami's own delivery rules.
Hanami.app.register_provider(:mailers, namespace: true) do
  prepare do
    require "hanami/mailer"
  end

  start do
    delivery_method =
      if Hanami.env?(:test)
        Hanami::Mailer::Delivery::Test.new
      elsif ENV["SMTP_ADDRESS"]
        Hanami::Mailer::Delivery::SMTP.new(
          address: ENV.fetch("SMTP_ADDRESS"),
          port: Integer(ENV.fetch("SMTP_PORT", 587)),
          domain: ENV.fetch("SMTP_DOMAIN", "localhost.localdomain"),
          user_name: ENV["SMTP_USERNAME"],
          password: ENV["SMTP_PASSWORD"],
          authentication: ENV["SMTP_AUTHENTICATION"]&.to_sym
        )
      else
        Burned::LogDelivery.new(target["logger"])
      end

    register "delivery_method", delivery_method
  end
end
