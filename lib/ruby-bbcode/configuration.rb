# Configuration holds RubyBBCode configuration
class Configuration
  # When true unknown tags are treated as text (default), otherwise an exception is raised
  attr_accessor :ignore_unknown_tags

  def initialize
    @ignore_unknown_tags = true
  end
end
