require 'test_helper'

class RubyBbcodeTest < Test::Unit::TestCase

  def test_enable_tags
    #assert_equal "<strong>foobar</strong>" , "[b]foobar[/b]".bbcode_to_html(true, {}, :enable, :b)
    assert_equal "<strong>[i]foobar[/i]</strong>", "[b][i]foobar[/i][/b]".bbcode_to_html(true, {}, :enable, :b)
    #assert_equal "<strong><em>foobar</em></strong>", "[b][i]foobar[/i][/b]".bbcode_to_html(true, {}, :enable, :b, :i)
  end
  
  
end
