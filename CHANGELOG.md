Upcoming
--------

* Support multiple errors within a text
* Add parameters to #bbcode_check_validity to add/remove tags
* Support regular tag parameters (`[tag param=value][/tag]`) instead of 'quick parameters' (`[tag=value][/tag]`)
* Changed tag description symbols (to become descriptive), **breaks existing custom tag additions!**
* Add support to show the BBCode annotated with errors (when there are any)
* Add support to escape token value using :uri_escape.
* Recognize uppercase tags (issue #27)
* Support [iframe-API](https://developers.google.com/youtube/iframe_api_reference) for YouTube videos (#18)
* Support difference between optional and required parameters
* Add optional parameters to youtube and vimeo tags to specify the dimensions of the video

Version 1.0.1 - 04-Jan-2015

* Allow any version of activesupport since 3.2.3

Version 1.0.0 - 11-Oct-2014
---------------------------

* Added 'self closing tags' option (enabled for [*])
* Added [list], [*] and [code] tags
* Removed deprecated method
* Renamed check_bbcode_validity to bbcode_check_validity
