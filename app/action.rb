# auto_register: false
# frozen_string_literal: true

require "hanami/action"
require "dry/monads"

module Rounds
  class Action < Hanami::Action
    # Provide `Success` and `Failure` for pattern matching on operation results
    include Dry::Monads[:result]
    include Deps["repos.user_repo"]

    before :authenticate!

    # Lets people who are not signed in reach this action.
    def self.public_action!
      @public_action = true
    end

    def self.public_action?
      @public_action == true
    end

    # Lets people who have not chosen a name yet reach this action.
    def self.unnamed_allowed!
      @unnamed_allowed = true
    end

    def self.unnamed_allowed?
      @unnamed_allowed == true
    end

    private

    def authenticate!(request, response)
      return if self.class.public_action?

      user = user_repo.find(request.session[:user_id])
      unless user
        response.session[:user_id] = nil
        response.redirect_to "/login"
      end

      request.env["rounds.user"] = user
      response.redirect_to "/welcome" if user[:name].nil? && !self.class.unnamed_allowed?
    end

    # Answers forged or stale form posts with 403 instead of an error page.
    def handle_invalid_csrf_token(_request, _response)
      halt 403, "Forbidden"
    end

    def current_user(request)
      request.env["rounds.user"]
    end

    def ajax?(request)
      request.env["HTTP_X_REQUESTED_WITH"] == "fetch"
    end
  end
end
