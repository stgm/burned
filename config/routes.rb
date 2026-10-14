# frozen_string_literal: true

module Rounds
  class Routes < Hanami::Routes
    root to: "home.show"

    get "/login", to: "sessions.new"
    post "/login", to: "sessions.create"
    get "/login/code", to: "sessions.code"
    post "/login/code", to: "sessions.verify"
    post "/logout", to: "sessions.destroy"

    get "/welcome", to: "profile.edit"
    post "/welcome", to: "profile.update"

    get "/people", to: "people.index"
    post "/people", to: "people.create"

    get "/teams", to: "teams.index"
    post "/teams", to: "teams.create"
    get "/teams/:id", to: "teams.show"
    get "/teams/:team_id/threads", to: "threads.index"
    get "/teams/:team_id/threads/new", to: "threads.new"
    post "/teams/:team_id/threads", to: "threads.create"
    get "/teams/:team_id/members", to: "members.index"
    post "/teams/:team_id/members", to: "members.create"

    post "/invitations/:id/accept", to: "invitations.accept"
    post "/invitations/:id/decline", to: "invitations.decline"

    get "/threads/:id", to: "threads.show"
    post "/threads/:id/messages", to: "messages.create"
    post "/threads/:id/quiet", to: "threads.quiet"
    post "/threads/:id/pin", to: "threads.pin"
    post "/threads/:id/split", to: "threads.split"

    get "/updates", to: "updates.show"

    get "/manifest.webmanifest", to: "pwa.manifest"
    get "/icon.svg", to: "pwa.icon"
  end
end
