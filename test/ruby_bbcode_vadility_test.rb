require 'test_helper'

class RubyBbcodeValidityTest < Minitest::Test
  def test_multiple_errors
    input = '[b]Bold not closed, [li]Illegal list item[/li]'
    errors = input.bbcode_check_validity
    assert_equal 2, errors.length
    assert_includes errors, "[b] not closed"
    assert_includes errors, "[li] can only be used in [ul] and [ol], so using it in a [b] tag is not allowed"
  end

  def test_illegal_items
    assert_equal ['[li] can only be used in [ul] and [ol]'],
                   '[li]Illegal item[/li]'.bbcode_check_validity
    assert_equal ['[li] can only be used in [ul] and [ol], so using it in a [b] tag is not allowed'],
                   '[b][li]Illegal item[/li][/b]'.bbcode_check_validity
  end

  def test_illegal_list_contents
    assert_equal ['[ul] can only contain [li] and [*] tags, so "Illegal list" is not allowed'],
                   '[ul]Illegal list[/ul]'.bbcode_check_validity
    assert_equal ['[ul] can only contain [li] and [*] tags, so [b] is not allowed'],
                   '[ul][b]Illegal list[/b][/ul]'.bbcode_check_validity
  end

  def test_illegal_list_contents_text_between_list_items
    assert_equal ['[ul] can only contain [li] and [*] tags, so "Illegal text" is not allowed'],
                   '[ul][li]item[/li]Illegal text[/ul]'.bbcode_check_validity
    assert_equal ['[ul] can only contain [li] and [*] tags, so "Illegal text" is not allowed'],
                   '[ul][li]item[/li]Illegal text[li]item[/li][/ul]'.bbcode_check_validity
  end

  def test_unordered_list_omit_closing
    errors = '[ul][li]item 1[li]item 2[/ul]'.bbcode_check_validity
    assert_equal 5, errors.length

    assert_includes errors, '[li] can only be used in [ul] and [ol], so using it in a [li] tag is not allowed'
    assert_includes errors, 'Closing tag [/ul] doesn\'t match [li]'
    assert_includes errors, '[ul] not closed'
    assert_includes errors, '[li] not closed' # twice
  end

  def test_illegal_link
    assert_equal ['The URL should start with http:// https://, ftp:// or /, instead of \'index.html\''], '[url=index.html]Home[/url]'.bbcode_check_validity
    assert_equal ['The URL should start with http:// https://, ftp:// or /, instead of \'www.google.com\''], '[url=www.google.com]Google[/url]'.bbcode_check_validity
    assert_equal ['The URL should start with http:// https://, ftp:// or /, instead of \'htfp://www.google.com\''], '[url]htfp://www.google.com[/url]'.bbcode_check_validity
  end

  def test_no_ending_tag
   assert_equal ["[b] not closed"], "this [b]should not be bold".bbcode_check_validity
  end

  def test_no_start_tag
    assert_equal ["Closing tag [/b] doesn't match an opening tag"], "this should not be bold[/b]".bbcode_check_validity
  end

  def test_different_start_and_ending_tags
    assert_equal ["Closing tag [/i] doesn't match [b]", "[b] not closed"], "this [b]should not do formatting[/i]".bbcode_check_validity
  end

  def test_failing_between_texts
    assert_equal ['No text between [img] and [/img] tags.'], '[img][/img]'.bbcode_check_validity
    assert_equal ['The URL should start with http:// https://, ftp:// or /, instead of \'illegal url\''], '[url]illegal url[/url]'.bbcode_check_validity
  end

  def test_failing_between_texts_on_multi_tags
    assert_equal "<span class='bbcode_error' data-bbcode-errors='[\"No text between [media] and [/media] tags.\"]'>[media]</span>[/media][b]E4Fbk52Mk1w[/b]",
                   '[media][/media][b]E4Fbk52Mk1w[/b]'.bbcode_show_errors
  end
  
  def test_succeeding_between_texts_for_multi_tags_explicitly_marked_to_require_between_false
    mydef = {
      :can_be_empty => {
        :require_between => false,
        :multi_tag => true,
        :description => 'This is a test',
        :example => '[test]Test here[/test]',
        :param_tokens => [{:token => :can_be_empty}]
      }
    }
    
    assert '[can_be_empty][/can_be_empty]'.bbcode_check_validity(mydef) == true
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
