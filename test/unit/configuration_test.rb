require 'test_helper'

class ConfigurationTest < MiniTest::Test
  def before_setup
    RubyBBCode.reset
  end

  def test_configuration
    assert_equal true, RubyBBCode.configuration.ignore_unknown_tags

    RubyBBCode.configuration.ignore_unknown_tags = false

    assert_equal false, RubyBBCode.configuration.ignore_unknown_tags
  end

  def test_configuration_reset
    assert_equal true, RubyBBCode.configuration.ignore_unknown_tags

    RubyBBCode.configuration.ignore_unknown_tags = false

    assert_equal false, RubyBBCode.configuration.ignore_unknown_tags

    RubyBBCode.reset

    assert_equal true, RubyBBCode.configuration.ignore_unknown_tags
  end

  def test_configuration_block
    assert_equal true, RubyBBCode.configuration.ignore_unknown_tags

    RubyBBCode.configure do |config|
      config.ignore_unknown_tags = false
    end

    assert_equal false, RubyBBCode.configuration.ignore_unknown_tags
  end
end
