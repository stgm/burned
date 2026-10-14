# frozen_string_literal: true

module Rounds
  module TestHelpers
    # Empties the database before each test and offers shortcuts to build people and teams.
    module Database
      def setup
        super
        db = Hanami.app["relations.users"].dataset.db
        %i[threads teams users].each { |table| db[table].delete }
        Hanami.app["mailers.delivery_method"].clear
      end

      def users = Hanami.app["repos.user_repo"]
      def teams = Hanami.app["repos.team_repo"]
      def threads = Hanami.app["repos.thread_repo"]
      def messages = Hanami.app["repos.message_repo"]

      def person(email, name, admin: false)
        user, = users.invite(email, admin: admin)
        users.set_name(user[:id], name)
      end

      # Builds a team where everyone listed is an active member. The first person owns it.
      def team_with(*people, name: "Crew")
        team = teams.create(name, people.first[:id])
        people.drop(1).each do |p|
          teams.invite(team[:id], p[:id], people.first[:id])
          teams.accept(teams.membership(team[:id], p[:id]))
        end
        team
      end

      def say(thread, user, body)
        Hanami.app["chat.post_message"].call(thread: thread, user: user, body: body).value!
      end

      def sent_mail = Hanami.app["mailers.delivery_method"].deliveries.map(&:message)
    end
  end
end

Hanami::Minitest::Test.include Rounds::TestHelpers::Database
