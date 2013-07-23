require 'test_helper'
require 'benchmark'



class RubyBbcodeTest < Test::Unit::TestCase
  
  

  

  def test_vimeo_tag
    input = "[vimeo]http://vimeo.com/46141999[/vimeo]"
    input2 = "[vimeo]46141955[/vimeo]"
    output = '<iframe src="http://player.vimeo.com/video/46141955?badge=0" width="500" height="281" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>'
    
    assert_equal output, input.bbcode_to_html
    assert_equal output, input2.bbcode_to_html
  end

=begin  
  def test_mulit_tag
    input1 = "[media]http://www.youtube.com/watch?v=cSohjlYQI2A[/media]"
    input2 = "[media]http://vimeo.com/46141955[/media]"
    output1 = "<object width=\"400\" height=\"325\"><param name=\"movie\" value=\"http://www.youtube.com/v/cSohjlYQI2A\"></param><embed src=\"http://www.youtube.com/v/cSohjlYQI2A\" type=\"application/x-shockwave-flash\" width=\"400\" height=\"325\"></embed></object>"
    output2 = '<iframe src="http://player.vimeo.com/video/46141955?badge=0" width="500" height="281" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>'
    
    assert_equal output1, input1.bbcode_to_html
  end

=begin  
  
  def test_youtube_with_full_url
    full_url = "http://www.youtube.com/watch?feature=player_embedded&v=E4Fbk52Mk1w"
    assert_equal '<object width="400" height="325"><param name="movie" value="http://www.youtube.com/v/E4Fbk52Mk1w"></param><embed src="http://www.youtube.com/v/E4Fbk52Mk1w" type="application/x-shockwave-flash" width="400" height="325"></embed></object>' ,
                   "[youtube]#{full_url}[/youtube]".bbcode_to_html
  end

=begin
  
  def test_youtube_with_url_shortener
    full_url = "http://www.youtu.be/cSohjlYQI2A"
    assert_equal '<object width="400" height="325"><param name="movie" value="http://www.youtube.com/v/cSohjlYQI2A"></param><embed src="http://www.youtube.com/v/cSohjlYQI2A" type="application/x-shockwave-flash" width="400" height="325"></embed></object>' ,
                   "[youtube]#{full_url}[/youtube]".bbcode_to_html
  end
  
=begin
  def test_google_video_with_full_url
    assert_equal '<embed id="VideoPlayback" src="http://video.google.com/googleplayer.swf?docid=397259729324681206&hl=en" style="width:400px; height:325px;" type="application/x-shockwave-flash"></embed>',
                   '[gvideo]397259729324681206[/gvideo]'.bbcode_to_html  #FIXME: insert proper full URL here...
  end
  
  def test_vimeo_tag
    input = "[vimeo]http://vimeo.com/46141955[/vimeo]"
    output = '<iframe src="http://player.vimeo.com/video/46141955?badge=0" width="500" height="281" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>'
    
    assert_equal output, input.bbcode_to_html
  end

=end

=begin
  def test_mulit_tag
    input1 = "[media]http://www.youtube.com/watch?v=cSohjlYQI2A[/media]"
    input2 = "[media]http://vimeo.com/46141955[/media]"
    output1 = "<object width=\"400\" height=\"325\"><param name=\"movie\" value=\"http://www.youtube.com/v/cSohjlYQI2A\"></param><embed src=\"http://www.youtube.com/v/cSohjlYQI2A\" type=\"application/x-shockwave-flash\" width=\"400\" height=\"325\"></embed></object>"
    output2 = '<iframe src="http://player.vimeo.com/video/46141955?badge=0" width="500" height="281" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>'
    
    
    assert_equal output1, input1.bbcode_to_html
    
    
  end
  
=end
end