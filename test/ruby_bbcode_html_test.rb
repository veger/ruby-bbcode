require 'test_helper'

class RubyBbcodeHtmlTest < Minitest::Test

  def test_multiline
    assert_equal "line1<br />\nline2", "line1\nline2".bbcode_to_html
    assert_equal "line1<br />\nline2", "line1\r\nline2".bbcode_to_html
  end

  def test_strong
    assert_equal '<strong>simple</strong>', '[b]simple[/b]'.bbcode_to_html
    assert_equal "<strong>line 1<br />\nline 2</strong>", "[b]line 1\nline 2[/b]".bbcode_to_html
  end

  def test_em
    assert_equal '<em>simple</em>', '[i]simple[/i]'.bbcode_to_html
    assert_equal "<em>line 1<br />\nline 2</em>", "[i]line 1\nline 2[/i]".bbcode_to_html
  end

  def test_u
    assert_equal '<u>simple</u>', '[u]simple[/u]'.bbcode_to_html
    assert_equal "<u>line 1<br />\nline 2</u>", "[u]line 1\nline 2[/u]".bbcode_to_html
  end

  def test_code
    assert_equal '<pre>simple</pre>', '[code]simple[/code]'.bbcode_to_html
    assert_equal "<pre>line 1<br />\nline 2</pre>", "[code]line 1\nline 2[/code]".bbcode_to_html
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

  def test_list_common_syntax
    assert_equal '<ul><li>item 1</li><li>item 2</li></ul>', '[list][*]item 1[*]item 2[/list]'.bbcode_to_html
  end

  def test_list_common_syntax_explicit_closing
    assert_equal '<ul><li>item 1</li><li>item 2</li></ul>', '[list][*]item 1[/*][*]item 2[/*][/list]'.bbcode_to_html
  end

  def test_two_lists
    assert_equal '<ul><li>item1</li><li>item2</li></ul><ul><li>item1</li><li>item2</li></ul>',
                   '[ul][li]item1[/li][li]item2[/li][/ul][ul][li]item1[/li][li]item2[/li][/ul]'.bbcode_to_html
  end

  def test_whitespace_in_only_allowed_tags
    assert_equal "<ol><br />\n<li>item 1</li><br />\n<li>item 2</li><br />\n</ol>",
                   "[ol]\n[li]item 1[/li]\n[li]item 2[/li]\n[/ol]".bbcode_to_html
    assert_equal "<ol> <li>item 1</li>  <li>item 2</li>\t</ol>",
                   "[ol] [li]item 1[/li]  [li]item 2[/li]\t[/ol]".bbcode_to_html
  end

  def test_quote
    assert_equal '<div class="quote">quoting</div>', '[quote]quoting[/quote]'.bbcode_to_html
    assert_equal '<div class="quote"><strong>someone wrote:</strong>quoting</div>', '[quote=someone]quoting[/quote]'.bbcode_to_html
    assert_equal '<div class="quote"><strong>Kitten wrote:</strong><div class="quote"><strong>creatiu wrote:</strong>f1</div>f2</div>',
                  '[quote=Kitten][quote=creatiu]f1[/quote]f2[/quote]'.bbcode_to_html
  end

  def test_link
    assert_equal '<a href="http://www.google.com">http://www.google.com</a>', '[url]http://www.google.com[/url]'.bbcode_to_html
    assert_equal '<a href="http://google.com">Google</a>', '[url=http://google.com]Google[/url]'.bbcode_to_html
    assert_equal '<a href="/index.html">Home</a>', '[url=/index.html]Home[/url]'.bbcode_to_html
  end

  def test_image
    assert_equal '<img src="http://www.ruby-lang.org/images/logo.gif" alt="" />',
                   '[img]http://www.ruby-lang.org/images/logo.gif[/img]'.bbcode_to_html
    assert_equal '<img src="http://www.ruby-lang.org/images/logo.gif" width="95" height="96" alt="" />',
                   '[img=95x96]http://www.ruby-lang.org/images/logo.gif[/img]'.bbcode_to_html
    assert_equal '<img src="http://www.ruby-lang.org/images/logo.gif" width="123" height="456" alt="" />',
                   '[img width=123 height=456]http://www.ruby-lang.org/images/logo.gif[/img]'.bbcode_to_html
  end

  def test_youtube
    assert_equal '<object width="400" height="325"><param name="movie" value="http://www.youtube.com/v/E4Fbk52Mk1w"></param><embed src="http://www.youtube.com/v/E4Fbk52Mk1w" type="application/x-shockwave-flash" width="400" height="325"></embed></object>',
                   '[youtube]E4Fbk52Mk1w[/youtube]'.bbcode_to_html
  end

  def test_youtube_with_full_url
    full_url = "http://www.youtube.com/watch?feature=player_embedded&v=E4Fbk52Mk1w"
    assert_equal '<object width="400" height="325"><param name="movie" value="http://www.youtube.com/v/E4Fbk52Mk1w"></param><embed src="http://www.youtube.com/v/E4Fbk52Mk1w" type="application/x-shockwave-flash" width="400" height="325"></embed></object>',
                   "[youtube]#{full_url}[/youtube]".bbcode_to_html
  end

  def test_youtube_with_url_shortener
    full_url = "http://www.youtu.be/cSohjlYQI2A"
    assert_equal '<object width="400" height="325"><param name="movie" value="http://www.youtube.com/v/cSohjlYQI2A"></param><embed src="http://www.youtube.com/v/cSohjlYQI2A" type="application/x-shockwave-flash" width="400" height="325"></embed></object>',
                   "[youtube]#{full_url}[/youtube]".bbcode_to_html
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
    assert_equal "[b]foobar[/b]", "[b]foobar[/b]".bbcode_to_html(true, {}, :disable, :b)
    assert_equal "[b]<em>foobar</em>[/b]", "[b][i]foobar[/i][/b]".bbcode_to_html(true, {}, :disable, :b)
    assert_equal "[b][i]foobar[/i][/b]", "[b][i]foobar[/i][/b]".bbcode_to_html(true, {}, :disable, :b, :i)
  end

  def test_enable_tags
    assert_equal "<strong>foobar</strong>" , "[b]foobar[/b]".bbcode_to_html(true, {}, :enable, :b)
    assert_equal "<strong>[i]foobar[/i]</strong>", "[b][i]foobar[/i][/b]".bbcode_to_html(true, {}, :enable, :b)
    assert_equal "<strong><em>foobar</em></strong>", "[b][i]foobar[/i][/b]".bbcode_to_html(true, {}, :enable, :b, :i)
  end

  def test_to_html_bang_method
    foo = "[b]foobar[/b]"
    assert_equal "<strong>foobar</strong>", foo.bbcode_to_html!
    assert_equal "<strong>foobar</strong>", foo
  end

  def test_addition_of_tags
    mydef = {
      :test => {
        :html_open => '<test>', :html_close => '</test>',
        :description => 'This is a test',
        :example => '[test]Test here[/test]'}
    }
    assert_equal 'pre <test>Test here</test> post', 'pre [test]Test here[/test] post'.bbcode_to_html(true, mydef)
    assert_equal 'pre <strong><test>Test here</test></strong> post', 'pre [b][test]Test here[/test][/b] post'.bbcode_to_html(true, mydef)
  end

  def test_multiple_tag_test
    assert_equal "<strong>bold</strong><em>italic</em><u>underline</u><div class=\"quote\">quote</div><a href=\"https://test.com\">link</a>",
                   "[b]bold[/b][i]italic[/i][u]underline[/u][quote]quote[/quote][url=https://test.com]link[/url]".bbcode_to_html
  end

  def test_no_xss_hax
    expected = "<a href=\"http://www.google.com&quot; onclick=\&quot;javascript:alert\">google</a>"
    assert_equal expected, '[url=http://www.google.com" onclick="javascript:alert]google[/url]'.bbcode_to_html
  end

  def test_media_tag
    input1 = "[media]http://www.youtube.com/watch?v=cSohjlYQI2A[/media]"
    input2 = "[media]http://vimeo.com/46141955[/media]"

    output1 = "<object width=\"400\" height=\"325\"><param name=\"movie\" value=\"http://www.youtube.com/v/cSohjlYQI2A\"></param><embed src=\"http://www.youtube.com/v/cSohjlYQI2A\" type=\"application/x-shockwave-flash\" width=\"400\" height=\"325\"></embed></object>"
    output2 = '<iframe src="http://player.vimeo.com/video/46141955?badge=0" width="500" height="281" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>'

    assert_equal output1, input1.bbcode_to_html
    assert_equal output2, input2.bbcode_to_html
  end

  def test_vimeo_tag
    input = "[vimeo]http://vimeo.com/46141955[/vimeo]"
    input2 = "[vimeo]46141955[/vimeo]"
    output = '<iframe src="http://player.vimeo.com/video/46141955?badge=0" width="500" height="281" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>'

    assert_equal output, input.bbcode_to_html
    assert_equal output, input2.bbcode_to_html
  end

  def test_failing_media_tag
    input1 = "[media]http://www.youtoob.com/watch?v=cSohjlYQI2A[/media]"

    assert_equal input1, input1.bbcode_to_html
  end

  def test_raised_exceptions
    # Test whether exceptions are raised when the BBCode contains errors
    assert_raises RuntimeError do
      'this [b]should raise an exception'.bbcode_to_html
    end
    assert_raises RuntimeError do
      '[ul][li]item 1[li]item 2[/ul]'.bbcode_to_html
    end
  end
end
