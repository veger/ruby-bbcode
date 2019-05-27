# Configuration holds RubyBBCode configuration
class Configuration
  # Defines how to treat unknown tags
  # * :exception throws and exception
  # * :text converts it into a text
  # * :ignore removes it from the output
  attr_reader :ignore_unknown_tags

  def initialize
    @ignore_unknown_tags = :text
  end

  def ignore_unknown_tags=(value)
    raise 'ignore_unknown_tags must be either :exception, :text or :ignore' unless %i[exception text ignore].include? value

    @ignore_unknown_tags = value
  end
end
