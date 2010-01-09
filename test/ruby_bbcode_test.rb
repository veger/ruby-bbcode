require 'test_helper'

class RubyBbcodeTest < Test::Unit::TestCase

  def test_strong
    assert_equal '[b]simple[/b]'.bbcode_to_html, '<strong>simple</strong>'
    assert_equal "[b]line 1\nline 2[/b]".bbcode_to_html, "<strong>line 1<br />\nline 2</strong>"
  end
  
  def test_em
    assert_equal '[i]simple[/i]'.bbcode_to_html, '<em>simple</em>'
    assert_equal "[i]line 1\nline 2[/i]".bbcode_to_html, "<em>line 1<br />\nline 2</em>"
  end
  
  def test_u
    assert_equal '[u]simple[/u]', '<u>simple</u>'.bbcode_to_html
    assert_equal "[u]line 1\nline 2[/u]", "<u>line 1<br />\nline 2</u>".bbcode_to_html
  end

  def test_strikethrough
    assert_equal '[s]simple[/s]'.bbcode_to_html, '<span style="text-decoration:line-through;">simple</span>'
    assert_equal "[s]line 1\nline 2[/s]".bbcode_to_html, "<span style=\"text-decoration:line-through;\">line 1<br />\nline 2</span>"
  end
  
  def test_size
    assert_equal '[size=32]12px Text[/size]'.bbcode_to_html, '<span style="font-size: 32px;">12px Text</span>'
  end
  
  def test_color
    assert_equal '[color=red]Red Text[/color]'.bbcode_to_html, '<span style="color: red;">Red Text</span>'
    assert_equal '[color=#ff0023]Hex Color Text[/color]'.bbcode_to_html, '<span style="color: #ff0023;">Hex Color Text</span>'
  end

  def test_center
    assert_equal '[center]centered[/center]'.bbcode_to_html, '<div style="text-align:center;">centered</div>'
  end
  
  def test_ordered_list
    assert_equal '[ol][li]item 1[/li][li]item 2[/li][/ol]'.bbcode_to_html, '<ol><li>item 1</li><li>item 2</li></ol>'
  end

  def test_unordered_list
    assert_equal '[ul][li]item 1[/li][li]item 2[/li][/ul]'.bbcode_to_html, '<ul><li>item 1</li><li>item 2</li></ul>'
  end
 
  def test_two_lists
    assert_equal '[ul][li]item1[/li][li]item2[/li][/ul][ul][li]item1[/li][li]item2[/li][/ul]'.bbcode_to_html,
                   '<ul><li>item1</li><li>item2</li></ul><ul><li>item1</li><li>item2</li></ul>'                
  end
  
  def test_quote
    assert_equal '[quote]quoting[/quote]'.bbcode_to_html, '<div class="quote">quoting</div>' 
    assert_equal '[quote=someone]quoting[/quote]'.bbcode_to_html, '<div class="quote"><strong>someone wrote:</strong>quoting</div>'
    assert_equal '[quote="Kitten"][quote="creatiu"]f1[/quote]f2[/quote]'.bbcode_to_html, 
                   '<div class="quote"><strong>Kitten wrote:</strong><div class="quote"><strong>creatiu wrote:</strong>f1</div>f2</div>'
                
  end
  
  def test_link
    assert_equal '[url=http://google.com]Google[/url]'.bbcode_to_html, '<a href="http://google.com">Google</a>'
    assert_equal '[url]http://google.com[/url]'.bbcode_to_html, '<a href="http://google.com">http://google.com</a>'
  end
  
  def test_image
    assert_equal '[img]http://www.ruby-lang.org/images/logo.gif[/img]'.bbcode_to_html,
                   '<img src="http://www.ruby-lang.org/images/logo.gif" alt="" />'
    assert_equal '[img size=95x96]http://www.ruby-lang.org/images/logo.gif[/img]'.bbcode_to_html, 
                   '<img src="http://www.ruby-lang.org/images/logo.gif" width="95" height="96" />'
  end
  
  def test_youtube
    assert_equal '[youtube]E4Fbk52Mk1w[/youtube]'.bbcode_to_html,
                   '<object width="400" height="325"><param name="movie" value="http://www.youtube.com/v/{param}"></param><embed src="http://www.youtube.com/v/E4Fbk52Mk1w" type="application/x-shockwave-flash" width="400" height="325"></embed></object>' 
  end
  
  def test_google_video
    assert_equal '[gvideo]397259729324681206[/gvideo]'.bbcode_to_html,
                   '<embed id="VideoPlayback" src="http://video.google.com/googleplayer.swf?docid=3972597293246812066&hl=en" style="width:500px; height:350px;" type="application/x-shockwave-flash"></embed>' 
  end

  def test_html_escaping
    assert_equal '[b]<i>foobar</i>[/b]'.bbcode_to_html, "<strong>&lt;i&gt;foobar&lt;/i&gt;</strong>"
    assert_equal '[b]<i>foobar</i>[/b]'.bbcode_to_html(false), "<strong><i>foobar</i></strong>" 
    assert_equal '1 is < 2'.bbcode_to_html, "1 is &lt; 2"
    assert_equal '1 is < 2'.bbcode_to_html(false), "1 is < 2"
    assert_equal '2 is > 1'.bbcode_to_html, "2 is &gt; 1"
    assert_equal '2 is > 1'.bbcode_to_html(false), "2 is > 1"
  end

  def test_disable_tags
    assert_equal "[b]foobar[/b]".bbcode_to_html(true, {}, :disable, :bold), "[b]foobar[/b]"
    assert_equal "[b][i]foobar[/i][/b]".bbcode_to_html(true, {}, :disable, :bold), "[b]<em>foobar</em>[/b]"
    assert_equal "[b][i]foobar[/i][/b]".bbcode_to_html(true, {}, :disable, :bold, :italic), "[b][i]foobar[/i][/b]"
  end

  def test_enable_tags
    assert_equal "[b]foobar[/b]".bbcode_to_html(true, {}, :enable, :bold), "<strong>foobar</strong>" 
    assert_equal "[b][i]foobar[/i][/b]".bbcode_to_html(true, {}, :enable, :bold), "<strong>[i]foobar[/i]</strong>"
    assert_equal "[b][i]foobar[/i][/b]".bbcode_to_html(true, {}, :enable, :bold, :italic), "<strong><em>foobar</em></strong>"
  end

  def test_to_html_bang_method
    foo = "[b]foobar[/b]"
    assert_equal foo.bbcode_to_html!, "<strong>foobar</strong>"
    assert_equal foo, "<strong>foobar</strong>"
  end

  def test_self_tag_list
    assert_equal RubyBBCode.tag_list.size, 14
  end
  
  def test_addition_of_tags
    mydef = {
      'test' => ['test',
        '<test>','</test>',
        'This is a test',
        '[test]Test here[/test]']
    }
    assert_equal 'pre [test]Test here[/test] post'.bbcode_to_html(true, mydef), 'pre <test>Test here</text> post'
    assert_equal 'pre [b][test]Test here[/test][/b] post'.bbcode_to_html(true, mydef), 'pre <strong><test>Test here</text></strong> post'
  end

  def test_multiple_tag_test
    assert_equal "[b]bold[/b][i]italic[/i][u]underline[/u][quote]quote[/quote][url=foobar]link[/url]".bbcode_to_html, 
                   "<strong>bold</strong><em>italic</em><u>underline</u><div class=\"quote\">quote</div><a href=\"foobar\">link</a>"
  end

  def test_no_ending_tag
    assert_equal "this [b]should not be bold".bbcode_to_html, "this [b]should not be bold" 
  end

  def test_no_start_tag
    assert_equal "this should not be bold[/b]".bbcode_to_html, "this should not be bold[/b]"
  end

  def test_different_start_and_ending_tags
    assert_equal "this [b]should not do formatting[/i]".bbcode_to_html, "this [b]should not do formatting[/i]"
  end

end
