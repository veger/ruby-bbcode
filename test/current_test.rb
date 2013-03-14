require 'test_helper'

class RubyBbcodeTest < Test::Unit::TestCase

  def test_multiline
    assert_equal "line1<br />\nline2", "line1\nline2".bbcode_to_html
    assert_equal "line1<br />\nline2", "line1\r\nline2".bbcode_to_html
  end
  
  
end
