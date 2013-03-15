require 'test_helper'

class RubyBbcodeTest < Test::Unit::TestCase

  def test_multiline
    "[b]I'm bold and the next word is [i]ITALLICS[/i][/b]".bbcode_to_html
  end
  
  
end
