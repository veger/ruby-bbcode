require 'test_helper'

class TagSifterTest < MiniTest::Test
  include RubyBBCode::Tags
  def test_youtube_parser
    url1 = "http://www.youtube.com/watch?v=E4Fbk52Mk1w"
    just_an_id = 'E4Fbk52Mk1w'
    url_without_http = "www.youtube.com/watch?v=E4Fbk52Mk1w"
    url_without_www = "youtube.com/watch?v=E4Fbk52Mk1w"
    url_with_feature = "http://www.youtube.com/watch?feature=player_embedded&v=E4Fbk52Mk1w"
    mock_regex_matches = @@tags[:youtube][:url_matches]

    expected_output = 'E4Fbk52Mk1w'

    RubyBBCode::TagSifter.publicize_methods do
      ts = RubyBBCode::TagSifter.new "", ""
      assert_equal expected_output, ts.match_url_id(url1, mock_regex_matches)
      assert_equal expected_output, ts.match_url_id(just_an_id, mock_regex_matches)
      assert_equal expected_output, ts.match_url_id(url_without_http, mock_regex_matches)
      assert_equal expected_output, ts.match_url_id(url_without_www, mock_regex_matches)
      assert_equal expected_output, ts.match_url_id(url_with_feature, mock_regex_matches)
    end

  end

  # I think the answer to this is creating a new tag named [youtube]
  # but that captures specifically the .be or .com and treats them differently...
  def test_youtubes_via_there_url_shortener
    url_from_shortener = "http://youtu.be/E4Fbk52Mk1w"
    directory_format = "http://youtube.googleapis.com/v/E4Fbk52Mk1w"
    expected_output = 'E4Fbk52Mk1w'
    mock_regex_matches = @@tags[:youtube][:url_matches]

    RubyBBCode::TagSifter.publicize_methods do
      ts = RubyBBCode::TagSifter.new "", ""

      # this test is now hopelessly broken because generating an ID from a link requires that @bbtree.current_node.definition be properly populated with regex matches...
      assert_equal expected_output, ts.match_url_id(url_from_shortener, mock_regex_matches)
    end
  end
end
