require 'test_helper'
require 'benchmark'



class RubyBbcodeTest < Test::Unit::TestCase
  
  
  def test_youtube_with_url_shortener
    full_url = "http://www.youtube.com/watch?feature=player_embedded&v=E4Fbk52Mk1w"
    assert_equal '<object width="400" height="325"><param name="movie" value="http://www.youtube.com/v/E4Fbk52Mk1w"></param><embed src="http://www.youtube.com/v/E4Fbk52Mk1w" type="application/x-shockwave-flash" width="400" height="325"></embed></object>' ,
                   "[youtube]#{full_url}[/youtube]".bbcode_to_html
  end
  
  
  def test_mulit_tag
    input1 = "[media]http://www.youtube.com/watch?v=cSohjlYQI2A[/media]"
    input2 = "[media]http://vimeo.com/46141955[/media]"
    output1 = "<object width=\"400\" height=\"325\"><param name=\"movie\" value=\"http://www.youtube.com/v/cSohjlYQI2A\"></param><embed src=\"http://www.youtube.com/v/cSohjlYQI2A\" type=\"application/x-shockwave-flash\" width=\"400\" height=\"325\"></embed></object>"
    output2 = '<iframe src="http://player.vimeo.com/video/46141955?badge=0" width="500" height="281" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe> <p><a href="http://vimeo.com/46141955">FEAR OF FLYING</a> from <a href="http://vimeo.com/conorfinnegan">conorfinnegan</a> on <a href="https://vimeo.com">Vimeo</a>.</p>'
    
    
    assert_equal output1, input1.bbcode_to_html
    
    
  end
end