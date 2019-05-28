require 'test_helper'

class RubyBbcodeBbcodeTest < Minitest::Test
  def before_setup
    RubyBBCode.reset
  end

  def test_multiline
    assert_equal "line1\nline2", "line1\nline2".bbcode_show_errors
    assert_equal "line1\r\nline2", "line1\r\nline2".bbcode_show_errors
  end

  def test_strong
    assert_equal '[b]simple[/b]', '[b]simple[/b]'.bbcode_show_errors
    assert_equal "[b]line 1\nline 2[/b]", "[b]line 1\nline 2[/b]".bbcode_show_errors
  end

  def test_em
    assert_equal '[i]simple[/i]', '[i]simple[/i]'.bbcode_show_errors
    assert_equal "[i]line 1\nline 2[/i]", "[i]line 1\nline 2[/i]".bbcode_show_errors
  end

  def test_u
    assert_equal '[u]simple[/u]', '[u]simple[/u]'.bbcode_show_errors
    assert_equal "[u]line 1\nline 2[/u]", "[u]line 1\nline 2[/u]".bbcode_show_errors
  end

  def test_code
    assert_equal '[code]simple[/code]', '[code]simple[/code]'.bbcode_show_errors
    assert_equal "[code]line 1\nline 2[/code]", "[code]line 1\nline 2[/code]".bbcode_show_errors
  end

  def test_strikethrough
    assert_equal '[s]simple[/s]', '[s]simple[/s]'.bbcode_show_errors
    assert_equal "[s]line 1\nline 2[/s]", "[s]line 1\nline 2[/s]".bbcode_show_errors
  end

  def test_size
    assert_equal '[size size=32]32px Text[/size]', '[size=32]32px Text[/size]'.bbcode_show_errors
  end

  def test_color
    assert_equal '[color color=red]Red Text[/color]', '[color=red]Red Text[/color]'.bbcode_show_errors
    assert_equal '[color color=#ff0023]Hex Color Text[/color]', '[color color=#ff0023]Hex Color Text[/color]'.bbcode_show_errors
  end

  def test_center
    assert_equal '[center]centered[/center]', '[center]centered[/center]'.bbcode_show_errors
  end

  def test_ordered_list
    assert_equal '[ol][li]item 1[/li][li]item 2[/li][/ol]', '[ol][li]item 1[/li][li]item 2[/li][/ol]'.bbcode_show_errors
    assert_equal "[ol]\n[li]item 1[/li]\n[li]item 2[/li]\n[/ol]", "[ol]\n[li]item 1[/li]\n[li]item 2[/li]\n[/ol]".bbcode_show_errors
  end

  def test_unordered_list
    assert_equal '[ul][li]item 1[/li][li]item 2[/li][/ul]', '[ul][li]item 1[/li][li]item 2[/li][/ul]'.bbcode_show_errors
    assert_equal "[ul]\n\t[li]item 1[/li]\n\t[li]item 2[/li]\n[/ul]", "[ul]\n\t[li]item 1[/li]\n\t[li]item 2[/li]\n[/ul]".bbcode_show_errors
  end

  def test_list_common_syntax
    assert_equal '[list][*]item 1[/*][*]item 2[/*][/list]', '[list][*]item 1[*]item 2[/list]'.bbcode_show_errors
    assert_equal "[list]\n[*]item 1[/*]\n[*]item 2[/*]\n[/list]", "[list]\n[*]item 1\n[*]item 2\n[/list]".bbcode_show_errors
  end

  def test_list_common_syntax_explicit_closing
    assert_equal '[list][*]item 1[/*][*]item 2[/*][/list]', '[list][*]item 1[/*][*]item 2[/*][/list]'.bbcode_show_errors
  end

  def test_two_lists
    assert_equal '[ul][li]item1[/li][li]item2[/li][/ul][ul][li]item1[/li][li]item2[/li][/ul]',
                 '[ul][li]item1[/li][li]item2[/li][/ul][ul][li]item1[/li][li]item2[/li][/ul]'.bbcode_show_errors
  end

  def test_whitespace_in_only_allowed_tags
    assert_equal "[ol]\n[li]item 1[/li]\n[li]item 2[/li]\n[/ol]",
                 "[ol]\n[li]item 1[/li]\n[li]item 2[/li]\n[/ol]".bbcode_show_errors
    assert_equal "[ol] [li]item 1[/li]  [li]item 2[/li]\t[/ol]",
                 "[ol] [li]item 1[/li]  [li]item 2[/li]\t[/ol]".bbcode_show_errors
  end

  def test_quote
    assert_equal '[quote]quoting[/quote]', '[quote]quoting[/quote]'.bbcode_show_errors
    assert_equal "[quote]\nquoting\n[/quote]", "[quote]\nquoting\n[/quote]".bbcode_show_errors
    assert_equal '[quote author=someone]quoting[/quote]', '[quote=someone]quoting[/quote]'.bbcode_show_errors
    assert_equal '[quote author=Kitten][quote author=creatiu]f1[/quote]f2[/quote]',
                 '[quote author=Kitten][quote=creatiu]f1[/quote]f2[/quote]'.bbcode_show_errors
  end

  def test_link
    assert_equal '[url url=http://www.google.com]http://www.google.com[/url]', '[url]http://www.google.com[/url]'.bbcode_show_errors
    assert_equal '[url url=http://google.com]Google[/url]', '[url=http://google.com]Google[/url]'.bbcode_show_errors
    assert_equal '[url url=http://google.com][b]Bold Google[/b][/url]', '[url=http://google.com][b]Bold Google[/b][/url]'.bbcode_show_errors
    assert_equal '[url url=/index.html]Home[/url]', '[url=/index.html]Home[/url]'.bbcode_show_errors
  end

  def test_image
    assert_equal '[img]http://www.ruby-lang.org/images/logo.gif[/img]',
                 '[img]http://www.ruby-lang.org/images/logo.gif[/img]'.bbcode_show_errors
    assert_equal '[img width=95 height=96]http://www.ruby-lang.org/images/logo.gif[/img]',
                 '[img=95x96]http://www.ruby-lang.org/images/logo.gif[/img]'.bbcode_show_errors
    assert_equal '[img width=123 height=456]http://www.ruby-lang.org/images/logo.gif[/img]',
                 '[img width=123 height=456]http://www.ruby-lang.org/images/logo.gif[/img]'.bbcode_show_errors
  end

  def test_youtube
    assert_equal '[youtube]E4Fbk52Mk1w[/youtube]',
                 '[youtube]E4Fbk52Mk1w[/youtube]'.bbcode_show_errors
  end

  def test_youtube_with_full_url
    assert_equal '[youtube]E4Fbk52Mk1w[/youtube]',
                 '[youtube]http://www.youtube.com/watch?feature=player_embedded&v=E4Fbk52Mk1w[/youtube]'.bbcode_show_errors
  end

  def test_youtube_with_url_shortener
    assert_equal '[youtube]cSohjlYQI2A[/youtube]',
                 '[youtube]http://www.youtu.be/cSohjlYQI2A[/youtube]'.bbcode_show_errors
  end

  def test_disable_tags
    assert_equal '[b]foobar[/b]', '[b]foobar[/b]'.bbcode_show_errors({}, :disable, :b)
    assert_equal '[b][i]foobar[/i][/b]', '[b][i]foobar[/i][/b]'.bbcode_show_errors({}, :disable, :b)
    assert_equal '[b][i]foobar[/i][/b]', '[b][i]foobar[/i][/b]'.bbcode_show_errors({}, :disable, :b, :i)
  end

  def test_enable_tags
    assert_equal '[b]foobar[/b]', '[b]foobar[/b]'.bbcode_show_errors({}, :enable, :b)
    assert_equal '[b][i]foobar[/i][/b]', '[b][i]foobar[/i][/b]'.bbcode_show_errors({}, :enable, :b)
    assert_equal '[b][i]foobar[/i][/b]', '[b][i]foobar[/i][/b]'.bbcode_show_errors({}, :enable, :b, :i)
  end

  def test_addition_of_tags
    mydef = {
      test: {
        html_open: '<test>', html_close: '</test>',
        description: 'This is a test',
        example: '[test]Test here[/test]'
      }
    }
    assert_equal 'pre [test]Test here[/test] post', 'pre [test]Test here[/test] post'.bbcode_show_errors(mydef)
    assert_equal 'pre [b][test]Test here[/test][/b] post', 'pre [b][test]Test here[/test][/b] post'.bbcode_show_errors(mydef)
  end

  def test_multiple_tag_test
    assert_equal '[b]bold[/b][i]italic[/i][u]underline[/u][quote]quote[/quote][url url=https://test.com]link[/url]',
                 '[b]bold[/b][i]italic[/i][u]underline[/u][quote]quote[/quote][url=https://test.com]link[/url]'.bbcode_show_errors
  end

  def test_no_xss_hax
    expected = "[url url=http://www.google.com' onclick='javascript:alert]google[/url]"
    assert_equal expected, "[url=http://www.google.com' onclick='javascript:alert]google[/url]".bbcode_show_errors
  end

  def test_media_tag
    assert_equal '[youtube]cSohjlYQI2A[/youtube]', '[media]http://www.youtube.com/watch?v=cSohjlYQI2A[/media]'.bbcode_show_errors
    assert_equal '[vimeo]46141955[/vimeo]', '[media]http://vimeo.com/46141955[/media]'.bbcode_show_errors
  end

  def test_vimeo_tag
    input = '[vimeo]http://vimeo.com/46141955[/vimeo]'
    input2 = '[vimeo]46141955[/vimeo]'

    assert_equal '[vimeo]46141955[/vimeo]', input.bbcode_show_errors
    assert_equal '[vimeo]46141955[/vimeo]', input2.bbcode_show_errors
  end

  def test_failing_media_tag
    assert_equal '<span class=\'bbcode_error\' data-bbcode-errors=\'["Unknown multi-tag type for [media]"]\'>[media]</span>http://www.youtoob.com/watch?v=cSohjlYQI2A[/media]', '[media]http://www.youtoob.com/watch?v=cSohjlYQI2A[/media]'.bbcode_show_errors
  end

  def test_wrong_tags
    assert_equal '<span class=\'bbcode_error\' data-bbcode-errors=\'["[b] not closed"]\'>[b]</span>Not closed', '[b]Not closed'.bbcode_show_errors
    assert_equal '<span class=\'bbcode_error\' data-bbcode-errors=\'["[b] not closed"]\'>[b]</span>2 not <span class=\'bbcode_error\' data-bbcode-errors=\'["[i] not closed"]\'>[i]</span>closed', '[b]2 not [i]closed'.bbcode_show_errors

    assert_equal 'Closing tag not matching<span class=\'bbcode_error\' data-bbcode-errors=\'["Closing tag [/b] doesn&#39;t match an opening tag"]\'>[/b]</span>', 'Closing tag not matching[/b]'.bbcode_show_errors

    assert_equal '<span class=\'bbcode_error\' data-bbcode-errors=\'["[b] not closed"]\'>[b]</span>Other closing tag<span class=\'bbcode_error\' data-bbcode-errors=\'["Closing tag [/i] doesn&#39;t match [b]"]\'>[/i]</span>', '[b]Other closing tag[/i]'.bbcode_show_errors
  end

  def test_failing_quick_param
    assert_equal '<span class=\'bbcode_error\' data-bbcode-errors=\'["The image parameters &#39;illegal&#39; are incorrect, &#39;<width>x<height>&#39; excepted"]\'>[img]</span>image[/img]', '[img=illegal]image[/img]'.bbcode_show_errors
  end

  def test_failing_between_texts
    assert_equal '<span class=\'bbcode_error\' data-bbcode-errors=\'["No text between [img] and [/img] tags."]\'>[img]</span>[/img]', '[img][/img]'.bbcode_show_errors
    assert_equal '[url]<span class=\'bbcode_error\' data-bbcode-errors=\'["The URL should start with http:// https://, ftp:// or /, instead of &#39;illegal url&#39;"]\'>illegal url</span>[/url]', '[url]illegal url[/url]'.bbcode_show_errors
    assert_equal '[url]<span class=\'bbcode_error\' data-bbcode-errors=\'["between parameter must be plain text"]\'>[b]</span>Bold Google[/b][/url]', '[url][b]Bold Google[/b][/url]'.bbcode_show_errors
  end

  def test_missing_parent_tags
    assert_equal '<span class=\'bbcode_error\' data-bbcode-errors=\'["[li] can only be used in [ul] and [ol]"]\'>[li]</span>[/li]', '[li][/li]'.bbcode_show_errors
  end

  def test_unknown_tag
    RubyBBCode.configuration.ignore_unknown_tags = :exception
    assert_raises RuntimeError do
      '[unknown]This is an unknown tag[/unknown]'.bbcode_show_errors
    end

    RubyBBCode.configuration.ignore_unknown_tags = :ignore
    assert_equal 'This is an unknown tag', '[unknown]This is an unknown tag[/unknown]'.bbcode_show_errors

    RubyBBCode.configuration.ignore_unknown_tags = :text
    assert_equal '[unknown]This is an unknown tag[/unknown]', '[unknown]This is an unknown tag[/unknown]'.bbcode_show_errors
  end

  def test_illegal_unallowed_childs
    assert_equal '[ul]<span class=\'bbcode_error\' data-bbcode-errors=\'["[ul] can only contain [li] and [*] tags, so &quot;Illegal text&quot; is not allowed"]\'>Illegal text</span>[/ul]', '[ul]Illegal text[/ul]'.bbcode_show_errors
    assert_equal '[ul]<span class=\'bbcode_error\' data-bbcode-errors=\'["[ul] can only contain [li] and [*] tags, so [b] is not allowed"]\'>[b]</span>Illegal tag[/b][/ul]', '[ul][b]Illegal tag[/b][/ul]'.bbcode_show_errors
  end
end
