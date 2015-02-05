require 'test_helper'

class RubyBbcodeValidityTest < Minitest::Test

  def test_unordered_list_omit_closing
    assert_raises RuntimeError do
      assert_equal '<ul><li>item 1</li><li>item 2</li></ul>', '[ul][li]item 1[li]item 2[/ul]'.bbcode_to_html
    end
  end

  def test_multiple_errors
    input = "[b]Bold not closed, [li]Illegal list item[/li]"
    errors = input.bbcode_check_validity
    assert_equal 2, errors.length
    assert_includes errors, "[b] not closed"
    assert_includes errors, "[li] can only be used in [ul] and [ol], so using it in a [b] tag is not allowed"
  end

  def test_illegal_items
    assert_raises RuntimeError do
      '[li]Illegal item[/li]'.bbcode_to_html
    end
    assert_equal ['[li] can only be used in [ul] and [ol]'],
                   '[li]Illegal item[/li]'.bbcode_check_validity
    assert_raises RuntimeError do
      '[b][li]Illegal item[/li][/b]'.bbcode_to_html
    end

    assert_equal ['[li] can only be used in [ul] and [ol], so using it in a [b] tag is not allowed'],
                   '[b][li]Illegal item[/li][/b]'.bbcode_check_validity
  end

  def test_illegal_list_contents
    assert_raises RuntimeError do
      '[ul]Illegal list[/ul]'.bbcode_to_html
    end
    assert_equal ['[ul] can only contain [li] and [*] tags, so "Illegal list" is not allowed'],
                   '[ul]Illegal list[/ul]'.bbcode_check_validity
    assert_raises RuntimeError do
      '[ul][b]Illegal list[/b][/ul]'.bbcode_to_html
    end
    assert_equal ['[ul] can only contain [li] and [*] tags, so [b] is not allowed'],
                   '[ul][b]Illegal list[/b][/ul]'.bbcode_check_validity
  end

  def test_illegal_list_contents_text_between_list_items
    assert_raises RuntimeError do
      '[ul][li]item[/li]Illegal list[/ul]'.bbcode_to_html
    end
    assert_equal ['[ul] can only contain [li] and [*] tags, so "Illegal text" is not allowed'],
                   '[ul][li]item[/li]Illegal text[/ul]'.bbcode_check_validity
    assert_raises RuntimeError do
      '[ul][li]item[/li]Illegal list[li]item[/li][/ul]'.bbcode_to_html
    end
    assert_equal ['[ul] can only contain [li] and [*] tags, so "Illegal text" is not allowed'],
                   '[ul][li]item[/li]Illegal text[li]item[/li][/ul]'.bbcode_check_validity
  end

  def test_illegal_link
    assert_raises RuntimeError do
      # Link within same domain must start with a /
      '[url=index.html]Home[/url]'.bbcode_to_html
    end
    assert_raises RuntimeError do
      # Link within same domain must start with a / and a link to another domain with http://, https:// or ftp://
      '[url=www.google.com]Google[/url]'.bbcode_to_html
    end
    assert_raises RuntimeError do
      '[url]htfp://www.google.com[/url]'.bbcode_to_html
    end
  end

  def test_no_ending_tag
    assert_raises RuntimeError do
      "this [b]should not be bold".bbcode_to_html
    end
  end

  def test_no_start_tag
    assert_raises RuntimeError do
      "this should not be bold[/b]".bbcode_to_html
    end
  end

  def test_different_start_and_ending_tags
    assert_raises RuntimeError do
      "this [b]should not do formatting[/i]".bbcode_to_html
    end
  end

  def test_failing_between_texts
    assert_equal ['No text between [img] and [/img] tags.'], '[img][/img]'.bbcode_check_validity
    assert_equal ['The URL should start with http:// https://, ftp:// or /, instead of \'illegal url\''], '[url]illegal url[/url]'.bbcode_check_validity
  end

  def test_addition_of_tags
    mydef = {
      :test => {
        :description => 'This is a test',
        :example => '[test]Test here[/test]',
        :param_tokens => [{:token => :param}]
      }
    }
    # Currently, unknown tags are treated as text and no (missing) parameter values are checked for bbcode_check_validity
    # So this test is quite boring
    assert 'pre [test]Test here[/test] post'.bbcode_check_validity
    assert 'pre [test]Test here[/test] post'.bbcode_check_validity(mydef)
  end

    # TODO:  This stack level problem should be validated during the validations
  #def test_stack_level_too_deep
  #  num = 2300  # increase this number if the test starts failing.  It's very near the tipping point
  #  openers = "[s]hi i'm" * num
  #  closers = "[/s]" * num
  #  assert_raise( SystemStackError ) do
  #    (openers+closers).bbcode_to_html
  #  end
  #end

end
