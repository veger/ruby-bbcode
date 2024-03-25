# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'ruby-bbcode/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'ruby-bbcode'
  s.version     = RubyBBCode::VERSION
  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.5.0'
  s.author      = 'Maarten Bezemer'
  s.email       = 'maarten.bezemer@gmail.com'
  s.homepage    = 'http://github.com/veger/ruby-bbcode'
  s.summary     = "ruby-bbcode-#{s.version}"
  s.description = 'Convert BBCode to HTML and check whether the BBCode is valid.'
  s.license     = 'MIT'

  s.files = Dir['lib/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.md', 'CHANGELOG.md']
  s.test_files = Dir['test/**/*']

  s.rdoc_options << '--title' << 'Ruby BBCode' << '--main' << 'README.md'
  s.extra_rdoc_files = ['README.md', 'CHANGELOG.md', 'MIT-LICENSE']

  s.add_dependency 'activesupport', '>= 4.2.2'
  s.add_development_dependency 'base64' # ruby 3.4 requires explicit dependencies
  s.add_development_dependency 'bigdecimal' # ruby 3.4 requires explicit dependencies
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'simplecov-lcov'
  s.add_development_dependency 'irb'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'solargraph'

  s.add_development_dependency 'term-ansicolor'
end
