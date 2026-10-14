# frozen_string_literal: true

require "cgi/escape"

module Rounds
  # Reads and renders the text of chat messages.
  module Text
    MENTION = /(?<![\w@])@([a-z0-9_]+)/i
    URL = %r{https?://[^\s<]+}

    # Lists the handles mentioned in a message.
    def self.handles(body)
      body.scan(MENTION).flatten.map(&:downcase).uniq
    end

    # Turns message text into safe HTML with links, mentions and line breaks.
    def self.to_html(body, known_handles = [])
      known = known_handles.map(&:downcase)
      escaped = CGI.escapeHTML(body.to_s)
      escaped = escaped.gsub(URL) do |url|
        trimmed = url.sub(/[.,;:!?)]+\z/, "")
        tail = url[trimmed.length..]
        %(<a href="#{trimmed}" target="_blank" rel="noopener noreferrer">#{trimmed}</a>#{tail})
      end
      escaped = escaped.gsub(MENTION) do |match|
        known.include?(Regexp.last_match(1).downcase) ? %(<span class="mention">#{match}</span>) : match
      end
      escaped.gsub("\n", "<br>")
    end

    # Returns up to two initials for a name, or for an email address when there is no name.
    def self.initials(name, email = nil)
      source = name.to_s.strip
      source = email.to_s.split("@").first.to_s.tr("._-", " ") if source.empty?
      letters = source.split.first(2).map { |word| word[0] }.join.upcase
      letters.empty? ? "?" : letters
    end
  end
end
