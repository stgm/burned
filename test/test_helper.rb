# frozen_string_literal: true

require "pathname"
TEST_ROOT = Pathname(__dir__).realpath.freeze

ENV["HANAMI_ENV"] ||= "test"
require "hanami/minitest"
require "hanami/prepare"

TEST_ROOT.glob("support/**/*.rb").each { |f| require f }
