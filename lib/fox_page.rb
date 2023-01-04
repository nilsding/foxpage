# frozen_string_literal: true

require "bundler"

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/foxpage.rb")
begin
  loader.ignore Bundler.root
rescue Bundler::GemfileNotFound # rubocop:disable Lint/HandleExceptions
  # don't care ...
end
loader.setup

require_relative "./fox_page/version"

module FoxPage
  class Error < StandardError; end

  OUTPUT_DIRECTORY = "_site"
end
