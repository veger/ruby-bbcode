require 'test_helper'

class ConfigurationTest < MiniTest::Test
  def before_setup
    RubyBBCode.reset
  end

  def test_configuration
    refute_equal :ignore, RubyBBCode.configuration.ignore_unknown_tags

    RubyBBCode.configuration.ignore_unknown_tags = :ignore

    assert_equal :ignore, RubyBBCode.configuration.ignore_unknown_tags
  end

  def test_configuration_reset
    refute_equal :exception, RubyBBCode.configuration.ignore_unknown_tags

    RubyBBCode.configuration.ignore_unknown_tags = :exception

    assert_equal :exception, RubyBBCode.configuration.ignore_unknown_tags

    RubyBBCode.reset

    refute_equal :exception, RubyBBCode.configuration.ignore_unknown_tags
  end

  def test_configuration_block
    refute_equal :ignore, RubyBBCode.configuration.ignore_unknown_tags

    RubyBBCode.configure do |config|
      config.ignore_unknown_tags = :ignore
    end

    assert_equal :ignore, RubyBBCode.configuration.ignore_unknown_tags
  end
end
