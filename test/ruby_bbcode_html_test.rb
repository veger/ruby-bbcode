require 'test_helper'

class RubyBbcodeHtmlTest < Minitest::Test
  def before_setup
    RubyBBCode.reset
  end

  def test_multiline
    assert_equal "line1<br />\nline2", "line1\nline2".bbcode_to_html
    assert_equal "line1<br />\nline2", "line1\r\nline2".bbcode_to_html
    assert_equal "<ul>\n<li>line1</li>\n<li>line2</li>\n</ul>", "[ul]\n[li]line1[/li]\n[li]line2[/li]\n[/ul]".bbcode_to_html
    assert_equal "<strong><br />\nline 1<br />\nline 2</strong>", "[b]\nline 1\nline 2[/b]".bbcode_to_html
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
    assert_equal '<ul><li><strong>item 1</strong> test</li><li>item 2</li></ul>', '[list][*][b]item 1[/b] test[*]item 2[/list]'.bbcode_to_html
  end

  def test_newline_list_common_syntax
    assert_equal "<ul>\n<li>item 1</li>\n<li>item 2</li>\n\n</ul>", "[list]\n[*]item 1\n[*]item 2\n\n[/list]".bbcode_to_html
  end

  def test_list_common_syntax_explicit_closing
    assert_equal '<ul><li>item 1</li><li>item 2</li></ul>', '[list][*]item 1[/*][*]item 2[/*][/list]'.bbcode_to_html
  end

  def test_two_lists
    assert_equal '<ul><li>item1</li><li>item2</li></ul><ul><li>item1</li><li>item2</li></ul>',
                 '[ul][li]item1[/li][li]item2[/li][/ul][ul][li]item1[/li][li]item2[/li][/ul]'.bbcode_to_html
  end

  def test_whitespace_in_only_allowed_tags
    assert_equal "<ol>\n<li>item 1</li>\n<li>item 2</li>\n</ol>",
                 "[ol]\n[li]item 1[/li]\n[li]item 2[/li]\n[/ol]".bbcode_to_html
    assert_equal "<ol> <li>item 1</li>  <li>item 2</li>\t</ol>",
                 "[ol] [li]item 1[/li]  [li]item 2[/li]\t[/ol]".bbcode_to_html
  end

  def test_quote
    assert_equal '<div class="quote">quoting</div>', '[quote]quoting[/quote]'.bbcode_to_html
    assert_equal "<div class=\"quote\">\nquoting\n</div>", "[quote]\nquoting\n[/quote]".bbcode_to_html
    assert_equal "<div class=\"quote\">\nfirst line<br />\nsecond line\n</div>", "[quote]\nfirst line\nsecond line\n[/quote]".bbcode_to_html
    assert_equal '<div class="quote"><strong>someone wrote:</strong>quoting</div>', '[quote=someone]quoting[/quote]'.bbcode_to_html
    assert_equal '<div class="quote"><strong>Kitten wrote:</strong><div class="quote"><strong>creatiu wrote:</strong>f1</div>f2</div>',
                 '[quote=Kitten][quote=creatiu]f1[/quote]f2[/quote]'.bbcode_to_html
  end

  def test_link
    assert_equal '<a href="http://www.google.com">http://www.google.com</a>', '[url]http://www.google.com[/url]'.bbcode_to_html
    assert_equal '<a href="http://google.com">Google</a>', '[url=http://google.com]Google[/url]'.bbcode_to_html
    assert_equal '<a href="http://google.com"><strong>Bold Google</strong></a>', '[url=http://google.com][b]Bold Google[/b][/url]'.bbcode_to_html
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
    assert_equal '<iframe id="player" type="text/html" width="400" height="320" src="http://www.youtube.com/embed/E4Fbk52Mk1w?enablejsapi=1" frameborder="0"></iframe>',
                 '[youtube]E4Fbk52Mk1w[/youtube]'.bbcode_to_html
    assert_equal '<iframe id="player" type="text/html" width="640" height="480" src="http://www.youtube.com/embed/E4Fbk52Mk1w?enablejsapi=1" frameborder="0"></iframe>',
                 '[youtube width=640 height=480]E4Fbk52Mk1w[/youtube]'.bbcode_to_html
  end

  def test_youtube_with_full_url
    full_url = 'http://www.youtube.com/watch?feature=player_embedded&v=E4Fbk52Mk1w'
    assert_equal '<iframe id="player" type="text/html" width="400" height="320" src="http://www.youtube.com/embed/E4Fbk52Mk1w?enablejsapi=1" frameborder="0"></iframe>',
                 "[youtube]#{full_url}[/youtube]".bbcode_to_html
  end

  def test_youtube_with_url_shortener
    full_url = 'http://www.youtu.be/cSohjlYQI2A'
    assert_equal '<iframe id="player" type="text/html" width="400" height="320" src="http://www.youtube.com/embed/cSohjlYQI2A?enablejsapi=1" frameborder="0"></iframe>',
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

  def test_uri_escaping
    # There is no tag available, so create our own to test URI escaping
    escape_param_def = {
      escapequery: {
        html_open: '<a href="%query%">%between%', html_close: '</a>',
        require_between: true, allow_quick_param: false, allow_between_as_param: true,
        param_tokens: [{ token: :query, uri_escape: true }]
      }
    }
    assert_equal '<a href="Escaped+string+%28to+be+used+as+URL+%26+more%29">Escaped string (to be used as URL & more)</a>',
                 '[escapequery]Escaped string (to be used as URL & more)[/escapequery]'.bbcode_to_html(true, escape_param_def)
    assert_equal '<a href="http%3A%3A%2Fwww.text.com%2Fpage.php%3Fparam1%3D1%26param2%3D2">http::/www.text.com/page.php?param1=1&param2=2</a>',
                 '[escapequery]http::/www.text.com/page.php?param1=1&param2=2[/escapequery]'.bbcode_to_html(true, escape_param_def)
  end

  def test_disable_tags
    assert_equal '[b]foobar[/b]', '[b]foobar[/b]'.bbcode_to_html(true, {}, :disable, :b)
    assert_equal '[b]<em>foobar</em>[/b]', '[b][i]foobar[/i][/b]'.bbcode_to_html(true, {}, :disable, :b)
    assert_equal '[b][i]foobar[/i][/b]', '[b][i]foobar[/i][/b]'.bbcode_to_html(true, {}, :disable, :b, :i)
  end

  def test_enable_tags
    assert_equal '<strong>foobar</strong>', '[b]foobar[/b]'.bbcode_to_html(true, {}, :enable, :b)
    assert_equal '<strong>[i]foobar[/i]</strong>', '[b][i]foobar[/i][/b]'.bbcode_to_html(true, {}, :enable, :b)
    assert_equal '<strong><em>foobar</em></strong>', '[b][i]foobar[/i][/b]'.bbcode_to_html(true, {}, :enable, :b, :i)
  end

  def test_to_html_bang_method
    foo = '[b]foobar[/b]'
    assert_equal '<strong>foobar</strong>', foo.bbcode_to_html!
    assert_equal '<strong>foobar</strong>', foo
  end

  def test_addition_of_tags
    mydef = {
      test: {
        html_open: '<test>', html_close: '</test>',
        description: 'This is a test',
        example: '[test]Test here[/test]'
      }
    }
    assert_equal 'pre <test>Test here</test> post', 'pre [test]Test here[/test] post'.bbcode_to_html(true, mydef)
    assert_equal 'pre <strong><test>Test here</test></strong> post', 'pre [b][test]Test here[/test][/b] post'.bbcode_to_html(true, mydef)
  end

  def test_multiple_tag_test
    assert_equal '<strong>bold</strong><em>italic</em><u>underline</u><div class="quote">quote</div><a href="https://test.com">link</a>',
                 '[b]bold[/b][i]italic[/i][u]underline[/u][quote]quote[/quote][url=https://test.com]link[/url]'.bbcode_to_html
  end

  def test_no_xss_hax
    expected = "<a href=\"http://www.google.com&quot; onclick=\&quot;javascript:alert\">google</a>"
    assert_equal expected, '[url=http://www.google.com" onclick="javascript:alert]google[/url]'.bbcode_to_html
  end

  def test_media_tag
    input1 = '[media]http://www.youtube.com/watch?v=cSohjlYQI2A[/media]'
    input2 = '[media]http://vimeo.com/46141955[/media]'

    output1 = '<iframe id="player" type="text/html" width="400" height="320" src="http://www.youtube.com/embed/cSohjlYQI2A?enablejsapi=1" frameborder="0"></iframe>'
    output2 = '<iframe src="http://player.vimeo.com/video/46141955?badge=0" width="400" height="320" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>'

    assert_equal output1, input1.bbcode_to_html
    assert_equal output2, input2.bbcode_to_html
  end

  def test_vimeo_tag
    input = '[vimeo]http://vimeo.com/46141955[/vimeo]'
    input2 = '[vimeo]46141955[/vimeo]'
    output = '<iframe src="http://player.vimeo.com/video/46141955?badge=0" width="400" height="320" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>'

    assert_equal output, input.bbcode_to_html
    assert_equal output, input2.bbcode_to_html

    assert_equal '<iframe src="http://player.vimeo.com/video/46141955?badge=0" width="640" height="480" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>',
                 '[vimeo width=640 height=480]46141955[/vimeo]'.bbcode_to_html
  end

  def test_unknown_tag
    RubyBBCode.configuration.ignore_unknown_tags = :exception
    assert_raises RuntimeError do
      '[unknown]This is an unknown tag[/unknown]'.bbcode_to_html
    end

    RubyBBCode.configuration.ignore_unknown_tags = :ignore
    assert_equal 'This is an unknown tag', '[unknown]This is an unknown tag[/unknown]'.bbcode_to_html

    RubyBBCode.configuration.ignore_unknown_tags = :text
    assert_equal '[unknown]This is an unknown tag[/unknown]', '[unknown]This is an unknown tag[/unknown]'.bbcode_to_html
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

  def test_uppercase
    assert_equal '<strong>simple</strong>', '[B]simple[/B]'.bbcode_to_html
    assert_equal "<strong>line 1<br />\nline 2</strong>", "[B]line 1\nline 2[/B]".bbcode_to_html
  end

  def test_uppercase_with_params
    assert_equal '<span style="font-size: 4px;">simple</span>', '[SIZE=4]simple[/SIZE]'.bbcode_to_html
    assert_equal "<span style=\"font-size: 4px;\">line 1<br />\nline 2</span>", "[SIZE=4]line 1\nline 2[/SIZE]".bbcode_to_html
  end

  def test_uppercase_at_tag_open
    assert_equal '<strong>simple</strong>', '[B]simple[/b]'.bbcode_to_html
    assert_equal "<strong>line 1<br />\nline 2</strong>", "[B]line 1\nline 2[/b]".bbcode_to_html
  end

  def test_uppercase_at_tag_close
    assert_equal '<strong>simple</strong>', '[b]simple[/B]'.bbcode_to_html
    assert_equal "<strong>line 1<br />\nline 2</strong>", "[b]line 1\nline 2[/B]".bbcode_to_html
  end

  def test_nested_uppercase_tags
    assert_equal '<ul><li>item 1</li><li>item 2</li></ul>', '[UL][LI]item 1[/LI][LI]item 2[/LI][/UL]'.bbcode_to_html
    assert_equal "<ul><li>line 1<br />\nline 2</li><li>line 1<br />\nline 2</li></ul>", "[UL][LI]line 1\nline 2[/LI][LI]line 1\nline 2[/LI][/UL]".bbcode_to_html
  end

  def test_parent_uppercase_in_nested_tags
    assert_equal '<ul><li>item 1</li><li>item 2</li></ul>', '[UL][li]item 1[/li][li]item 2[/li][/UL]'.bbcode_to_html
    assert_equal "<ul><li>line 1<br />\nline 2</li><li>line 1<br />\nline 2</li></ul>", "[UL][li]line 1\nline 2[/li][li]line 1\nline 2[/li][/UL]".bbcode_to_html
  end

  # Checking the HTML output is the only way to see whether a tag is recognized
  # The BBCode validity test ignores unknown tags (and treats them as text)
  def test_modified_taglist
    assert_equal '<strong>simple</strong>', '[b]simple[/b]'.bbcode_to_html

    tags = RubyBBCode::Tags.tag_list
    b_tag = tags.delete :b
    begin
      # Make sure we captured the contents of the b-tag
      assert b_tag.instance_of? Hash

      # Now no HTML is generated, as the tag is removed
      assert_equal '[b]simple[/b]', '[b]simple[/b]'.bbcode_to_html
    ensure
      # Always restore as this change is permanent (and messes with other tests)
      tags[:b] = b_tag
    end

    # Restored to the original/correct situation
    assert_equal '<strong>simple</strong>', '[b]simple[/b]'.bbcode_to_html
  end
end
