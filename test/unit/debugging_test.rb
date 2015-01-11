require 'test_helper'
require 'debugging'

class RubyBbcodeTest < Minitest::Test
  include ::RubyBBCode::Tags
  
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
    
    tags = @@tags
    @tag_sifter = RubyBBCode::TagSifter.new(text, tags)
    @tag_sifter.process_text
    
    # manually include the debugging methods if they've been disabled for cleanliness purposes
    @tag_sifter.bbtree.extend(::RubyBBCode::DebugBBTree) unless @tag_sifter.bbtree.respond_to? :to_v
    
    assert_equal visual, @tag_sifter.bbtree.to_v
  end
  
  def test_bbtree_counting_nodes
    text = "[ol][li][b][/b][b][/b][b][/b][b][/b]item 1[/li][li]item 2[/li][/ol]"
    tags = @@tags
    
    @tag_sifter = RubyBBCode::TagSifter.new(text, tags)
    
    @tag_sifter.process_text
    
    # manually include debugging methods if needed.  
    @tag_sifter.bbtree.extend(::RubyBBCode::DebugBBTree) unless @tag_sifter.bbtree.respond_to? :count_child_nodes
    
    assert_equal 9, @tag_sifter.bbtree.count_child_nodes
  end
  
end
