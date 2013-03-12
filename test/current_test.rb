require 'test_helper'

class RubyBbcodeTest < Test::Unit::TestCase

	def test_youtube
		assert_equal '<object width="400" height="325"><param name="movie" value="http://www.youtube.com/v/E4Fbk52Mk1w"></param><embed src="http://www.youtube.com/v/E4Fbk52Mk1w" type="application/x-shockwave-flash" width="400" height="325"></embed></object>' ,
			                   '[youtube]E4Fbk52Mk1w[/youtube]'.bbcode_to_html
	end
end
