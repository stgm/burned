# frozen_string_literal: true

require "hanami/db/repo"

module Burned
  module DB
    class Repo < Hanami::DB::Repo
      # Runs the block in a transaction.
      def transaction(&block)
        db.transaction(&block)
      end

      private

      # Returns the Sequel connection, for queries that join several tables.
      def db
        container.gateways[:default].connection
      end

      def now
        Time.now.utc
      end
    end
  end
end
