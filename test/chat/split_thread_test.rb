# frozen_string_literal: true

require "test_helper"

class SplitThreadTest < Hanami::Minitest::Test
  def setup
    super
    @ann = person("ann@example.com", "Ann")
    @bo = person("bo@example.com", "Bo")
    @team = team_with(@ann, @bo)
    @thread = threads.create(team_id: @team[:id], user_id: @ann[:id], title: "Lunch")
    @first = say(@thread, @ann, "pizza or ramen?")
    @second = say(@thread, @bo, "ramen")
    @third = say(@thread, @ann, "what about tomorrow?")
  end

  def split(ids, title: "Ramen")
    Hanami.app["chat.split_thread"].call(thread: @thread, user: @ann, message_ids: ids, title: title)
  end

  test "moves messages to a new thread and leaves a link behind" do
    new_thread = split([@first, @second]).value!

    assert_equal ["pizza or ramen?", "ramen"], messages.list(new_thread[:id]).map { _1[:body] }
    assert_equal @thread[:id], new_thread[:source_thread_id]

    old = messages.list(@thread[:id])
    assert_equal %w[text thread_link], old.map { _1[:kind] }
    assert_equal new_thread[:id], old.last[:linked_thread_id]
    assert_equal "Ramen", old.last[:linked_title]
  end

  test "uses the first message as the title when none is given" do
    assert_equal "pizza or ramen?", split([@first], title: "").value![:title]
  end

  test "fails when nothing is selected" do
    assert_equal :no_messages, split([]).failure
  end

  test "ignores ids that belong to another thread" do
    other = threads.create(team_id: @team[:id], user_id: @ann[:id], title: "Other")
    foreign = say(other, @ann, "elsewhere")
    assert_equal :no_messages, split([foreign]).failure
  end

  test "keeps messages that were already read as read" do
    threads.mark_read(@thread[:id], @bo[:id], @third)
    new_thread = split([@first, @second]).value!
    assert_equal 0, threads.list(@team[:id], @bo[:id]).find { _1[:id] == new_thread[:id] }[:unread]
  end
end
