require 'test_helper'

class RubyBbcodeTest < Test::Unit::TestCase

  def test_illegal_link
    #binding.pry
    assert_raise RuntimeError do
      # Link within same domain must start with a /
      '[url=index.html]Home[/url]'.bbcode_to_html
    end
    assert_raise RuntimeError do
      # Link within same domain must start with a / and a link to another domain with http://, https:// or ftp://
      '[url=www.google.com]Google[/url]'.bbcode_to_html
    end
  end
end
