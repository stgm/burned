# frozen_string_literal: true

require "test_helper"

class BubblingTest < Hanami::Minitest::Test
  def setup
    super
    @ann = person("ann@example.com", "Ann")
    @bo = person("bo@example.com", "Bo")
    @team = team_with(@ann, @bo)
    @thread = threads.create(team_id: @team[:id], user_id: @ann[:id], title: "Lunch")
  end

  def bubbling?(user)
    threads.list(@team[:id], user[:id]).first[:bubbling]
  end

  test "bubbles on every message by default" do
    say(@thread, @ann, "hello")
    assert bubbling?(@bo)
  end

  test "does not bubble for the author" do
    say(@thread, @ann, "hello")
    refute bubbling?(@ann)
  end

  test "stops bubbling once the thread is read" do
    id = say(@thread, @ann, "hello")
    threads.mark_read(@thread[:id], @bo[:id], id)
    refute bubbling?(@bo)
  end

  test "mentions level bubbles only on a mention" do
    threads.set_level(@thread[:id], @bo[:id], "mentions")
    say(@thread, @ann, "hello")
    refute bubbling?(@bo)
    say(@thread, @ann, "hello @bo")
    assert bubbling?(@bo)
  end

  test "never level does not bubble but stays listed" do
    threads.set_level(@thread[:id], @bo[:id], "never")
    say(@thread, @ann, "hello @bo")
    refute bubbling?(@bo)
    assert_equal 1, threads.list(@team[:id], @bo[:id]).size
  end

  test "lists bubbling threads first and quiet threads last" do
    quiet = threads.create(team_id: @team[:id], user_id: @ann[:id], title: "Quiet")
    loud = threads.create(team_id: @team[:id], user_id: @ann[:id], title: "Loud")
    plain = threads.create(team_id: @team[:id], user_id: @ann[:id], title: "Plain")
    threads.set_level(quiet[:id], @bo[:id], "never")
    say(quiet, @ann, "psst")
    say(loud, @ann, "hey")
    titles = threads.list(@team[:id], @bo[:id]).map { _1[:title] }
    assert_equal "Loud", titles.first
    assert_equal "Quiet", titles.last
    assert_includes titles, plain[:title]
  end

  test "pinned threads come first for everyone, in the order they were pinned" do
    a = threads.create(team_id: @team[:id], user_id: @ann[:id], title: "A")
    b = threads.create(team_id: @team[:id], user_id: @ann[:id], title: "B")
    c = threads.create(team_id: @team[:id], user_id: @ann[:id], title: "C")
    say(c, @ann, "loud")
    threads.set_pinned(b[:id], true)
    sleep 0.01
    threads.set_pinned(a[:id], true)

    [@ann, @bo].each do |user|
      assert_equal %w[B A], threads.list(@team[:id], user[:id]).first(2).map { _1[:title] }
    end

    threads.set_pinned(b[:id], false)
    assert_equal "A", threads.list(@team[:id], @bo[:id]).first[:title]
  end

  test "recent lists threads the person posted in, across teams" do
    other = team_with(@bo, @ann, name: "Other")
    elsewhere = threads.create(team_id: other[:id], user_id: @bo[:id], title: "Elsewhere")
    say(@thread, @bo, "mine")
    say(elsewhere, @bo, "mine too")
    say(@thread, @ann, "not counted for bo")
    assert_equal ["Elsewhere", "Lunch"], threads.recent(@bo[:id]).map { _1[:title] }
    assert_equal ["Lunch"], threads.recent(@ann[:id]).map { _1[:title] }
  end

  test "counts bubbling threads per team" do
    say(@thread, @ann, "hello")
    assert_equal({@team[:id] => 1}, threads.bubbling_by_team(@bo[:id]))
    assert_empty threads.bubbling_by_team(@ann[:id])
  end
end
