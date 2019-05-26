Upcoming
--------

* Use rubocup and sonargraph and fix minor issues

Version 2.0.3 - 07-Feb-2018
---------------------------

* Require Ruby version 2.3.0 or higher
* Require activesupport version 4.2.2 or higher

Version 2.0.2 - 10-Apr-2017
---------------------------

* Fix error when tags are in self-closing tags (issue #30)

Version 2.0.1 - 15-Jan-2017
---------------------------

* Remove EOL newlines before/after self-closing tags (issue #29)

Version 2.0.0 - 09-Apr-2015
---------------------------

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
---------------------------

* Allow any version of activesupport since 3.2.3

Version 1.0.0 - 11-Oct-2014
---------------------------

* Added 'self closing tags' option (enabled for [*])
* Added [list], [*] and [code] tags
* Removed deprecated method
* Renamed check_bbcode_validity to bbcode_check_validity
