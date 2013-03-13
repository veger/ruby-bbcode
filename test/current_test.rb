require 'test_helper'

class RubyBbcodeTest < Test::Unit::TestCase

  def test_addition_of_tags
    mydef = {
      :test => {
        :html_open => '<test>', :html_close => '</test>',
        :description => 'This is a test',
        :example => '[test]Test here[/test]'}
    }
    assert_equal 'pre <test>Test here</test> post', 'pre [test]Test here[/test] post'.bbcode_to_html(true, mydef)
    #assert_equal 'pre <strong><test>Test here</test></strong> post', 'pre [b][test]Test here[/test][/b] post'.bbcode_to_html(true, mydef)
  end
  
  
end
