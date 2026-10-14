# frozen_string_literal: true

require "test_helper"

class ChatTest < Hanami::Minitest::RequestTest
  def setup
    super
    @ann = person("ann@example.com", "Ann")
    @bo = person("bo@example.com", "Bo")
    @cy = person("cy@example.com", "Cy")
    @team = team_with(@ann, @bo)
    @thread = threads.create(team_id: @team[:id], user_id: @ann[:id], title: "Lunch")
  end

  def sign_in(user)
    get "/login"
    post "/login", _csrf_token: csrf, email: user[:email]
    post "/login/code", _csrf_token: csrf("/login/code"), code: sent_mail.last.text_body[/\d{6}/]
  end

  def csrf(path = nil)
    get path if path
    last_response.body[/name="_csrf_token" value="([^"]+)"/, 1] || begin
      get "/login"
      last_response.body[/name="_csrf_token" value="([^"]+)"/, 1]
    end
  end

  test "sends visitors to the sign-in page" do
    get "/"
    assert_equal 302, last_response.status
    assert_equal "/login", URI(last_response["location"]).path
  end

  test "signing in opens the most recent thread" do
    sign_in(@ann)
    get "/"
    assert_equal "/threads/#{@thread[:id]}", URI(last_response["location"]).path
  end

  test "asks new people for a name first" do
    new = users.invite("new@example.com").first
    sign_in(new)
    get "/"
    assert_equal "/welcome", URI(last_response["location"]).path
  end

  test "shows a thread to team members" do
    say(@thread, @ann, "hello there")
    sign_in(@bo)
    get "/threads/#{@thread[:id]}"
    assert_equal 200, last_response.status
    assert_includes last_response.body, "hello there"
  end

  test "hides threads from people outside the team" do
    sign_in(@cy)
    get "/threads/#{@thread[:id]}"
    assert_equal 404, last_response.status
  end

  test "posts a message and marks it as mention" do
    sign_in(@ann)
    get "/threads/#{@thread[:id]}"
    post "/threads/#{@thread[:id]}/messages", { _csrf_token: csrf, body: "hi @bo" }, "HTTP_X_REQUESTED_WITH" => "fetch"
    assert_equal 204, last_response.status
    assert_equal 1, Hanami.app["relations.mentions"].dataset.where(user_id: @bo[:id]).count
  end

  test "updates return new messages only" do
    first = say(@thread, @ann, "one")
    say(@thread, @ann, "two")
    sign_in(@bo)
    get "/updates", thread_id: @thread[:id], after: first
    assert_includes last_response.body, "two"
    refute_includes last_response.body, ">one<"
  end

  test "inviting a person who has an account mails them and adds a pending invitation" do
    sign_in(@ann)
    get "/teams/#{@team[:id]}/members"
    post "/teams/#{@team[:id]}/members", _csrf_token: csrf, email: "cy@example.com"
    assert_equal "cy@example.com", sent_mail.last.to.first
    assert_equal 1, teams.invitations_for(@cy[:id]).size
  end

  test "any member can pin a thread, outsiders cannot" do
    sign_in(@bo)
    post "/threads/#{@thread[:id]}/pin", pinned: "1"
    assert threads.find(@thread[:id])[:pinned_at]

    sign_in(@cy)
    post "/threads/#{@thread[:id]}/pin", pinned: "0"
    assert_equal 404, last_response.status
    assert threads.find(@thread[:id])[:pinned_at]
  end

  test "only admins can invite people to the app" do
    sign_in(@bo)
    get "/people"
    assert_equal 403, last_response.status
  end

  test "serves the manifest without signing in" do
    get "/manifest.webmanifest"
    assert_equal 200, last_response.status
    assert_equal "Rounds", JSON.parse(last_response.body)["name"]
  end
end
