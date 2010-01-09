require 'test_helper'

class RubyBbcodeTest < Test::Unit::TestCase

  def test_strong
    assert_equal '<strong>simple</strong>', '[b]simple[/b]'.bbcode_to_html
    assert_equal "<strong>line 1<br />\nline 2</strong>", "[b]line 1\nline 2[/b]".bbcode_to_html
  end
  
  def test_em
    assert_equal '<em>simple</em>', '[i]simple[/i]'.bbcode_to_html
    assert_equal "<em>line 1<br />\nline 2</em>", "[i]line 1\nline 2[/i]".bbcode_to_html
  end
  
  def test_u
    assert_equal '<u>simple</u>'.bbcode_to_html, '[u]simple[/u]'
    assert_equal "<u>line 1<br />\nline 2</u>".bbcode_to_html, "[u]line 1\nline 2[/u]"
  end

  def test_strikethrough
    assert_equal '<span style="text-decoration:line-through;">simple</span>', '[s]simple[/s]'.bbcode_to_html
    assert_equal "<span style=\"text-decoration:line-through;\">line 1<br />\nline 2</span>", "[s]line 1\nline 2[/s]".bbcode_to_html
  end
  
  def test_size
    assert_equal '<span style="font-size: 32px;">32px Text</span>', '[size=32]32px Text[/size]'.bbcode_to_html
  end
  
  def test_color
    assert_equal '<span style="color: red;">Red Text</span>', '[color=red]Red Text[/color]'.bbcode_to_html
    assert_equal '<span style="color: #ff0023;">Hex Color Text</span>', '[color=#ff0023]Hex Color Text[/color]'.bbcode_to_html
  end

  def test_center
    assert_equal '<div style="text-align:center;">centered</div>', '[center]centered[/center]'.bbcode_to_html
  end
  
  def test_ordered_list
    assert_equal '<ol><li>item 1</li><li>item 2</li></ol>', '[ol][li]item 1[/li][li]item 2[/li][/ol]'.bbcode_to_html
  end

  def test_unordered_list
    assert_equal '<ul><li>item 1</li><li>item 2</li></ul>', '[ul][li]item 1[/li][li]item 2[/li][/ul]'.bbcode_to_html
  end
 
  def test_two_lists
    assert_equal '<ul><li>item1</li><li>item2</li></ul><ul><li>item1</li><li>item2</li></ul>',
                   '[ul][li]item1[/li][li]item2[/li][/ul][ul][li]item1[/li][li]item2[/li][/ul]'.bbcode_to_html
  end
  
  def test_quote
    assert_equal '<div class="quote">quoting</div>',  '[quote]quoting[/quote]'.bbcode_to_html
    assert_equal '<div class="quote"><strong>someone wrote:</strong>quoting</div>', '[quote=someone]quoting[/quote]'.bbcode_to_html
    assert_equal '<div class="quote"><strong>Kitten wrote:</strong><div class="quote"><strong>creatiu wrote:</strong>f1</div>f2</div>',
                  '[quote="Kitten"][quote="creatiu"]f1[/quote]f2[/quote]'.bbcode_to_html
  end
  
  def test_link
    assert_equal '<a href="http://google.com">Google</a>', '[url=http://google.com]Google[/url]'.bbcode_to_html
    assert_equal '<a href="http://google.com">http://google.com</a>', '[url]http://google.com[/url]'.bbcode_to_html
  end
  
  def test_image
    assert_equal '<img src="http://www.ruby-lang.org/images/logo.gif" alt="" />',
                   '[img]http://www.ruby-lang.org/images/logo.gif[/img]'.bbcode_to_html
    assert_equal '<img src="http://www.ruby-lang.org/images/logo.gif" width="95" height="96" />', 
                   '[img size=95x96]http://www.ruby-lang.org/images/logo.gif[/img]'.bbcode_to_html
  end
  
  def test_youtube
    assert_equal '<object width="400" height="325"><param name="movie" value="http://www.youtube.com/v/{param}"></param><embed src="http://www.youtube.com/v/E4Fbk52Mk1w" type="application/x-shockwave-flash" width="400" height="325"></embed></object>' ,
                   '[youtube]E4Fbk52Mk1w[/youtube]'.bbcode_to_html
  end
  
  def test_google_video
    assert_equal '<embed id="VideoPlayback" src="http://video.google.com/googleplayer.swf?docid=3972597293246812066&hl=en" style="width:500px; height:350px;" type="application/x-shockwave-flash"></embed>',
                   '[gvideo]397259729324681206[/gvideo]'.bbcode_to_html
  end

  def test_html_escaping
    assert_equal '<strong>&lt;i&gt;foobar&lt;/i&gt;</strong>', '[b]<i>foobar</i>[/b]'.bbcode_to_html
    assert_equal '<strong><i>foobar</i></strong>', '[b]<i>foobar</i>[/b]'.bbcode_to_html(false)
    assert_equal '1 is &lt; 2', '1 is < 2'.bbcode_to_html
    assert_equal '1 is < 2', '1 is < 2'.bbcode_to_html(false)
    assert_equal '2 is &gt; 1', '2 is > 1'.bbcode_to_html
    assert_equal '2 is > 1', '2 is > 1'.bbcode_to_html(false)
  end

  def test_disable_tags
    assert_equal "[b]foobar[/b]", "[b]foobar[/b]".bbcode_to_html(true, {}, :disable, :bold)
    assert_equal "[b]<em>foobar</em>[/b]", "[b][i]foobar[/i][/b]".bbcode_to_html(true, {}, :disable, :bold)
    assert_equal "[b][i]foobar[/i][/b]", "[b][i]foobar[/i][/b]".bbcode_to_html(true, {}, :disable, :bold, :italic)
  end

  def test_enable_tags
    assert_equal "<strong>foobar</strong>" , "[b]foobar[/b]".bbcode_to_html(true, {}, :enable, :bold)
    assert_equal "<strong>[i]foobar[/i]</strong>", "[b][i]foobar[/i][/b]".bbcode_to_html(true, {}, :enable, :bold)
    assert_equal "<strong><em>foobar</em></strong>", "[b][i]foobar[/i][/b]".bbcode_to_html(true, {}, :enable, :bold, :italic)
  end

  def test_to_html_bang_method
    foo = "[b]foobar[/b]"
    assert_equal "<strong>foobar</strong>", foo.bbcode_to_html!
    assert_equal "<strong>foobar</strong>", foo
  end

  def test_self_tag_list
    assert_equal 14, RubyBBCode.tag_list.size
  end
  
  def test_addition_of_tags
    mydef = {
      'test' => ['test',
        '<test>','</test>',
        'This is a test',
        '[test]Test here[/test]']
    }
    assert_equal 'pre <test>Test here</text> post', 'pre [test]Test here[/test] post'.bbcode_to_html(true, mydef)
    assert_equal 'pre <strong><test>Test here</text></strong> post', 'pre [b][test]Test here[/test][/b] post'.bbcode_to_html(true, mydef)
  end

  def test_multiple_tag_test
    assert_equal "<strong>bold</strong><em>italic</em><u>underline</u><div class=\"quote\">quote</div><a href=\"foobar\">link</a>",
                   "[b]bold[/b][i]italic[/i][u]underline[/u][quote]quote[/quote][url=foobar]link[/url]".bbcode_to_html
  end

  def test_no_ending_tag
    assert_equal "this [b]should not be bold", "this [b]should not be bold".bbcode_to_html 
  end

  def test_no_start_tag
    assert_equal "this should not be bold[/b]", "this should not be bold[/b]".bbcode_to_html
  end

  def test_different_start_and_ending_tags
    assert_equal "this [b]should not do formatting[/i]", "this [b]should not do formatting[/i]".bbcode_to_html
  end

end
