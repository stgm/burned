# frozen_string_literal: true

require "json"

module Burned
  module Actions
    module Pwa
      # Describes the app so phones can install it to the home screen.
      class Manifest < Burned::Action
        public_action!

        def handle(_request, response)
          response.headers["Content-Type"] = "application/manifest+json"
          response.body = JSON.generate(
            name: "Burned", short_name: "Burned", start_url: "/", display: "standalone",
            background_color: "#12221b", theme_color: "#12221b",
            icons: [{src: "/icon.svg", sizes: "any", type: "image/svg+xml", purpose: "any"}]
          )
        end
      end
    end
  end
end
