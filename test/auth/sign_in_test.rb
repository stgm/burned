# frozen_string_literal: true

require "test_helper"

class SignInTest < Hanami::Minitest::Test
  def setup
    super
    @ann = person("ann@example.com", "Ann")
  end

  def request_code(email = "ann@example.com")
    Hanami.app["auth.request_code"].call(email)
  end

  def mailed_code
    sent_mail.last.text_body[/\d{6}/]
  end

  def verify(code, email = "ann@example.com")
    Hanami.app["auth.verify_code"].call(email, code)
  end

  test "mails a code that signs the person in" do
    request_code
    assert_equal ["ann@example.com"], sent_mail.last.to
    assert_equal @ann[:id], verify(mailed_code).value![:id]
  end

  test "a code works once" do
    request_code
    code = mailed_code
    verify(code)
    assert verify(code).failure?
  end

  test "a wrong code fails" do
    request_code
    wrong = mailed_code == "000000" ? "000001" : "000000"
    assert_equal :invalid, verify(wrong).failure
  end

  test "locks the code after too many wrong attempts" do
    request_code
    code = mailed_code
    6.times { verify("999999") }
    assert verify(code).failure?
  end

  test "sends nothing to unknown addresses" do
    request_code("stranger@example.com")
    assert_empty sent_mail
  end

  test "does not mail again within thirty seconds" do
    2.times { request_code }
    assert_equal 1, sent_mail.size
  end

  test "an expired code fails" do
    request_code
    Hanami.app["relations.login_codes"].dataset.update(expires_at: Time.now.utc - 1)
    assert_equal :expired, verify(mailed_code).failure
  end
end
