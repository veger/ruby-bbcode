require 'test_helper'

class RubyBbcodeTest < Test::Unit::TestCase
  
  def test_bbtree_to_v
    text = "[i][b]a[/b][b]a[/b][b]a[/b][b]a[/b]item 1[/i][i]item 2[/i]"
    visual = <<eos
i
  b
    "a"
  b
    "a"
  b
    "a"
  b
    "a"
  "item 1"
i
  "item 2"
eos
    
    tags = RubyBBCode.tag_list
    @tag_sifter = RubyBBCode::TagSifter.new(text, tags)
    @tag_sifter.process_text
    
    assert_equal visual, @tag_sifter.bbtree.to_v
  end
    
  
end