require 'test_helper'

class RubyBbcodeTest < Test::Unit::TestCase

  def test_illegal_items
    assert_equal ['[li] can only be used in [ul] and [ol]'],
                   '[li]Illegal item[/li]'.is_valid_bbcode?
  end
  
  
end
