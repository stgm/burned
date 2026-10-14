# frozen_string_literal: true

module Rounds
  module Actions
    module Pwa
      class Icon < Rounds::Action
        public_action!

        SVG = <<~SVG
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
            <rect width="512" height="512" rx="112" fill="#12221b"/>
            <circle cx="256" cy="256" r="170" fill="#ff7b6b"/>
            <text x="256" y="320" font-family="Georgia, serif" font-style="italic" font-weight="700"
              font-size="220" text-anchor="middle" fill="#12221b" stroke="#ffd23f" stroke-width="6">Bu</text>
          </svg>
        SVG

        def handle(_request, response)
          response.headers["Content-Type"] = "image/svg+xml"
          response.headers["Cache-Control"] = "public, max-age=86400"
          response.body = SVG
        end
      end
    end
  end
end
