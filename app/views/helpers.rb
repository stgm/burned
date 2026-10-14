# auto_register: false
# frozen_string_literal: true

require "cgi/escape"

module Rounds
  module Views
    module Helpers
      FONTS = [
        ["Georgia, 'Times New Roman', serif", "italic", 700],
        ["'Courier New', Courier, monospace", "normal", 700],
        ["'Brush Script MT', 'Snell Roundhand', cursive", "italic", 400],
        ["Impact, 'Arial Narrow Bold', sans-serif", "normal", 400],
        ["'Avenir Next Rounded', ui-rounded, 'Trebuchet MS', sans-serif", "normal", 800],
        ["Palatino, 'Book Antiqua', serif", "normal", 800],
        ["'Marker Felt', 'Comic Sans MS', fantasy", "normal", 700],
        ["Optima, Candara, sans-serif", "italic", 700],
        ["Copperplate, 'Copperplate Gothic Light', fantasy", "normal", 700],
        ["'American Typewriter', 'Courier New', serif", "normal", 700]
      ].freeze

      # Each palette holds a background, a text color and an accent color.
      PALETTES = [
        %w[#ffd23f #1b1b3a #ee4266], %w[#1b1b3a #ffd23f #ee4266], %w[#ee4266 #fff5e1 #1b1b3a],
        %w[#3bceac #0b3d3a #ffffff], %w[#0b3d3a #3bceac #ffd23f], %w[#7b2cbf #ffe8ff #ff9e00],
        %w[#ff9e00 #3c096c #ffffff], %w[#f4f1de #e07a5f #3d405b], %w[#3d405b #f4f1de #e07a5f],
        %w[#90e0ef #03045e #ff6b6b], %w[#2b2d42 #edf2f4 #ef233c], %w[#b7e4c7 #1b4332 #ffb703],
        %w[#ffafcc #3a0ca3 #ffffff], %w[#264653 #f4a261 #e9c46a]
      ].freeze

      SHAPES = [
        "50%", "32%", "50% 50% 50% 12%", "62% 38% 55% 45% / 45% 58% 42% 55%", "18%",
        "50% 12% 50% 12%", "40% 60% 60% 40% / 60% 40% 60% 40%"
      ].freeze

      TEXT_EFFECTS = %w[shadow outline glow double emboss plain].freeze
      RING_EFFECTS = %w[none ring offset dashed].freeze

      # Draws a person's initials in a style that stays the same for that person.
      def avatar(name:, look:, email: nil, size: "md")
        rng = Random.new(look.to_i)
        bg, fg, ac = PALETTES.sample(random: rng)
        family, style, weight = FONTS.sample(random: rng)
        radius = SHAPES.sample(random: rng)
        rotation = rng.rand(-6..6)
        text_fx = TEXT_EFFECTS.sample(random: rng)
        ring_fx = RING_EFFECTS.sample(random: rng)
        css = "--abg:#{bg};--afg:#{fg};--aac:#{ac};--ff:#{family};--fst:#{style};--fw:#{weight};" \
              "--r:#{radius};--rot:#{rotation}deg"
        initials = Text.initials(name, email)
        raw(
          %(<span class="av av-#{size} tx-#{text_fx} rg-#{ring_fx}" style="#{CGI.escapeHTML(css)}" ) +
          %(aria-hidden="true"><span class="av-in">#{CGI.escapeHTML(initials)}</span></span>)
        )
      end

      def person_avatar(person, size: "md")
        avatar(name: person[:name], look: person[:look], email: person[:email], size: size)
      end

      def author_avatar(message, size: "md")
        avatar(name: message[:author_name], look: message[:author_look], email: message[:author_email], size: size)
      end

      def message_html(message, handles)
        raw(Text.to_html(message[:body], handles))
      end

      def time_tag(time, css: "when")
        iso = time.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
        raw(%(<time class="#{css}" datetime="#{iso}">#{time.utc.strftime("%H:%M")}</time>))
      end

      def pin_icon
        raw('<svg class="pin" viewBox="0 0 16 16" width="12" height="12" aria-label="Pinned" role="img">' \
            '<path fill="currentColor" d="M9.5 1.5 14.5 6.5l-1.4.4-2.3 2.3.3 3.2-1 1L6.6 10l-3.9 3.9-.7-.7L5.9 9.3 2.6 6l1-1 3.2.3 2.3-2.3z"/></svg>')
      end

      def thread_path(thread)
        "/threads/#{thread.is_a?(Hash) ? thread[:id] : thread}"
      end

      def team_path(team)
        "/teams/#{team.is_a?(Hash) ? team[:id] : team}"
      end

      def csrf_field
        raw(%(<input type="hidden" name="_csrf_token" value="#{CGI.escapeHTML(csrf_token.to_s)}">))
      end

      LEVEL_LABELS = {"all" => "every message", "mentions" => "@mentions", "never" => "quiet"}.freeze

      # Returns the number shown on a bubbling thread: unread messages, or mentions for the @mentions level.
      def bubble_count(thread)
        thread[:level] == "mentions" ? thread[:mentioned] : thread[:unread]
      end

      # Returns a short line about the latest message of a thread.
      def preview_text(thread)
        last = thread[:preview]
        return "" unless last
        return "Moved messages to #{last[:body]}" if last[:kind] == "thread_link"

        text = last[:body].to_s.gsub(/\s+/, " ")
        text = "#{text[0, 90]}…" if text.length > 90
        "#{last[:author_name]}: #{text}"
      end
    end
  end
end
