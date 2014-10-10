$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ruby-bbcode/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ruby-bbcode"
  s.version     = RubyBbcode::VERSION
  s.authors     = ["Maarten Bezemer"]
  s.email       = ["maarten.bezemer@gmail.com"]
  s.homepage    = "http://github.com/veger/ruby-bbcode"
  s.summary     = "ruby-bbcode-#{s.version}"
  s.description = "Convert BBCode to HTML and check whether the BBCode is valid."

  s.files = Dir["lib/**/*"] + ["MIT-LICENSE", "Rakefile", "README.textile"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'activesupport'
  s.add_development_dependency 'rake'
end
