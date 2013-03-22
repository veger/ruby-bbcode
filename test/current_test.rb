require 'test_helper'

class RubyBbcodeTest < Test::Unit::TestCase

  def test_whitespace_in_only_allowed_tags
    assert_equal "<ol><br />\n<li>item 1</li><br />\n<li>item 2</li><br />\n</ol>", 
                   "[ol]\n[li]item 1[/li]\n[li]item 2[/li]\n[/ol]".bbcode_to_html
        assert_equal "<ol> <li>item 1</li>  <li>item 2</li> </ol>", 
                   "[ol] [li]item 1[/li]  [li]item 2[/li] [/ol]".bbcode_to_html

  end
  
  
end
