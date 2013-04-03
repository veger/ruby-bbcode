require 'test_helper'

class TagSifterTest < Test::Unit::TestCase
  def test_youtube_parser
    url1 = "http://www.youtube.com/watch?v=E4Fbk52Mk1w"
    just_an_id = 'E4Fbk52Mk1w'
    url_without_http = "www.youtube.com/watch?v=E4Fbk52Mk1w"
    url_without_www = "youtube.com/watch?v=E4Fbk52Mk1w"
    url_with_feature = "http://www.youtube.com/watch?feature=player_embedded&v=E4Fbk52Mk1w"
    
    expected_output = 'E4Fbk52Mk1w'
    
    require 'pry'
    
    ::RubyBBCode::TagSifter.publicize_methods do
      ts = ::RubyBBCode::TagSifter.new "[quote]hi[/quote]", ""
      binding.pry
      assert_equal expected_output, 
                     ts.parse_youtube_id(url1)
      
      assert_equal expected_output, 
                   ts.parse_youtube_id(just_an_id)
                   
      assert_equal expected_output, 
                     ts.parse_youtube_id(url_without_http)
                     
      assert_equal expected_output, 
                     ts.parse_youtube_id(url_without_www)
                     
      assert_equal expected_output, 
                     ts.parse_youtube_id(url_with_feature)
    end
    
  end
end
