require 'test_helper'

class RubyBbcodeTest < Test::Unit::TestCase

  #def test_whitespace_in_only_allowed_tags
    #assert_equal "<ol><br />\n<li>item 1</li><br />\n<li>item 2</li><br />\n</ol>", 
    #               "[ol]\n[li]item 1[/li]\n[li]item 2[/li]\n[/ol]".bbcode_to_html
    #assert_equal "<ol> <li>item 1</li>  <li>item 2</li> </ol>", 
    #           "[ol] [li]item 1[/li]  [li]item 2[/li] [/ol]".bbcode_to_html

  #end
=begin
  def test_counting_nodes
    text = "[ol][li][b][/b][b][/b][b][/b][b][/b]item 1[/li][li]item 2[/li][/ol]"
    tags = RubyBBCode.tag_list
    
    @tag_sifter = RubyBBCode::TagSifter.new(text, tags)
    
    @tag_sifter.process_text
    
    assert_equal 9, @tag_sifter.bbtree.count_child_nodes
  end
=end
  
  def test_bbtree_to_v
    # text = "[ol][li][b]a[/b][b]a[/b][b]a[/b][b]a[/b]item 1[/li][li]item 2[/li][/ol]"
    text = "[i][b]a[/b][b]a[/b][b]a[/b][b]a[/b]item 1 hey[/i][i]item 2[/i]"
    
    visual = <<eos
i
  b
  b
  b
  b
  "item 1"
i
  "item 2"
eos
    
    tags = RubyBBCode.tag_list
    @tag_sifter = RubyBBCode::TagSifter.new(text, tags)
    
    @tag_sifter.process_text
    
    puts visual
    puts @tag_sifter.bbtree.to_v
    
    assert_equal visual, @tag_sifter.bbtree.to_v
  end
  
end
