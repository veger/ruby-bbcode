$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ruby-bbcode/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ruby-bbcode"
  s.version     = RubyBBCode::VERSION
  s.platform    = Gem::Platform::RUBY
  s.author      = "Maarten Bezemer"
  s.email       = "maarten.bezemer@gmail.com"
  s.homepage    = "http://github.com/veger/ruby-bbcode"
  s.summary     = "ruby-bbcode-#{s.version}"
  s.description = "Convert BBCode to HTML and check whether the BBCode is valid."
  s.license     = "MIT"

  s.files = Dir["lib/**/*"] + ["MIT-LICENSE", "Rakefile", "README.textile"]
  s.test_files = Dir["test/**/*"]

  s.rdoc_options << '--title' << 'Ruby BBCode' << '--main' << 'README.md'
  s.extra_rdoc_files = ['README.textile', 'MIT-LICENSE']

  s.add_dependency 'activesupport'
  s.add_development_dependency 'rake'
end
