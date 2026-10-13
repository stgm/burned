# frozen_string_literal: true

require "securerandom"

module Burned
  module Repos
    class UserRepo < Burned::DB::Repo
      def find(id)
        return nil if id.nil?

        db[:users].where(id: id).first
      end

      def find_by_email(email)
        db[:users].where(email: normalize(email)).first
      end

      def all
        db[:users].order(:email).all
      end

      def find_by_handles(handles)
        return [] if handles.empty?

        db[:users].where(handle: handles).all
      end

      # Adds a person who may sign in. Returns the existing person when the address is known.
      def invite(email, admin: false)
        email = normalize(email)
        existing = find_by_email(email)
        return [existing, false] if existing

        id = db[:users].insert(
          email: email, admin: admin, look: SecureRandom.random_number(1_000_000),
          invited_at: now, created_at: now, updated_at: now
        )
        [find(id), true]
      end

      def set_name(id, name)
        user = find(id)
        handle = user[:handle] || unique_handle(name)
        db[:users].where(id: id).update(name: name.strip, handle: handle, updated_at: now)
        find(id)
      end

      def normalize(email)
        email.to_s.strip.downcase
      end

      private

      def unique_handle(name)
        base = name.unicode_normalize(:nfd).gsub(/\p{Mn}/, "").split.first.to_s.downcase.gsub(/[^a-z0-9_]/, "")
        base = "user" if base.empty?
        handle = base
        n = 1
        while db[:users].where(handle: handle).count.positive?
          n += 1
          handle = "#{base}#{n}"
        end
        handle
      end
    end
  end
end
