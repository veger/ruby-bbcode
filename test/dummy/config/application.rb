require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require
require "ruby-bbcode"

module Dummy
  class Application < Rails::Application
   # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"
  end
end

