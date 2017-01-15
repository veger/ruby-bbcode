require 'test_helper'

class TagSifterTest < MiniTest::Test
  def test_taglist_modification
    tags = RubyBBCode::Tags.tag_list
    assert_nil RubyBBCode::Tags.tag_list[:test]
    begin
      tags[:test] = 'test'

      assert_equal 'test', RubyBBCode::Tags.tag_list[:test]
    ensure
      # Always restore as this change is permanent (and messes with other tests)
      tags.delete :test
    end
    assert_nil RubyBBCode::Tags.tag_list[:test]
  end
end
