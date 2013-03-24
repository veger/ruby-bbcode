require 'test_helper'

class RubyBbcodeTest < Test::Unit::TestCase

  def test_bbtree_counting_nodes
    text = "[s][b][/b][b][/b][b][/b][b][/b]item 1[/s][s]item 2[/s]"
    tags = RubyBBCode.tag_list
    
    @tag_sifter = RubyBBCode::TagSifter.new(text, tags)
    
    @tag_sifter.process_text
    
    assert_equal 8, @tag_sifter.bbtree.count_child_nodes
  end
  
  
  

end
