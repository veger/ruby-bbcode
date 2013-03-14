require 'test_helper'

class RubyBbcodeTest < Test::Unit::TestCase

  def test_multiple_tag_test
    assert_equal "<strong>bold</strong><em>italic</em><u>underline</u><div class=\"quote\">quote</div><a href=\"https://test.com\">link</a>",
                   "[b]bold[/b][i]italic[/i][u]underline[/u][quote]quote[/quote][url=https://test.com]link[/url]".bbcode_to_html
  end
  
  
end
