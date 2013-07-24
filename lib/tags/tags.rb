module RubyBBCode
  module Tags
    # tagname => tag, HTML open tag, HTML close tag, description, example
    # All of these entrys are represented as @dictionary in the classes (or as the variable tags)
    # A single item from this file (eg the :b entry) is refered to as a @definition
    @@tags = {
      :b => {
        :html_open => '<strong>', :html_close => '</strong>',
        :description => 'Make text bold',
        :example => 'This is [b]bold[/b].'},
      :i => {
        :html_open => '<em>', :html_close => '</em>',
        :description => 'Make text italic',
        :example => 'This is [i]italic[/i].'},
      :u => {
        :html_open => '<u>', :html_close => '</u>',
        :description => 'Underline text',
        :example => 'This is [u]underlined[/u].'},
      :s => {
        :html_open => '<span style="text-decoration:line-through;">', :html_close => '</span>',
        :description => 'Strike-through text',
        :example => 'This is [s]wrong[/s] good.'},
      :center => {
        :html_open => '<div style="text-align:center;">', :html_close => '</div>',
        :description => 'Center a text',
        :example => '[center]This is centered[/center].'},
      :ul => {
        :html_open => '<ul>', :html_close => '</ul>',
        :description => 'Unordered list',
        :example => '[ul][li]List item[/li][li]Another list item[/li][/ul].',
        :only_allow => [ :li ]},
      :ol => {
        :html_open => '<ol>', :html_close => '</ol>',
        :description => 'Ordered list',
        :example => '[ol][li]List item[/li][li]Another list item[/li][/ol].',
        :only_allow => [ :li ]},
      :li => {
        :html_open => '<li>', :html_close => '</li>',
        :description => 'List item',
        :example => '[ul][li]List item[/li][li]Another list item[/li][/ul].',
        :only_in => [ :ul, :ol ]},
      :img => {
        :html_open => '<img src="%between%" %width%%height%alt="" />', :html_close => '',
        :description => 'Image',
        :example => '[img]http://www.google.com/intl/en_ALL/images/logo.gif[/img].',
        :only_allow => [],
        :require_between => true,
        :allow_tag_param => true, :allow_tag_param_between => false,
        :tag_param => /^(\d*)x(\d*)$/,
        :tag_param_tokens => [{:token => :width, :prefix => 'width="', :postfix => '" ' },
                              { :token => :height,  :prefix => 'height="', :postfix => '" ' } ],
        :tag_param_description => 'The image parameters \'%param%\' are incorrect, <width>x<height> excepted'},
      :url => {
        :html_open => '<a href="%url%">%between%', :html_close => '</a>',
        :description => 'Link to another page',
        :example => '[url]http://www.google.com/[/url].',
        :only_allow => [],
        :require_between => true,
        :allow_tag_param => true, :allow_tag_param_between => true,
        :tag_param => /^((((http|https|ftp):\/\/)|\/).+)$/, :tag_param_tokens => [{ :token => :url }],
        :tag_param_description => 'The URL should start with http:// https://, ftp:// or /, instead of \'%param%\'' },
      :quote => {
        :html_open => '<div class="quote">%author%', :html_close => '</div>',
        :description => 'Quote another person',
        :example => '[quote]BBCode is great[/quote]',
        :allow_tag_param => true, :allow_tag_param_between => false,
        :tag_param => /(.*)/,
        :tag_param_tokens => [{:token => :author, :prefix => '<strong>', :postfix => ' wrote:</strong>'}]},
      :size => {
        :html_open => '<span style="font-size: %size%px;">', :html_close => '</span>',
        :description => 'Change the size of the text',
        :example => '[size=32]This is 32px[/size]',
        :allow_tag_param => true, :allow_tag_param_between => false,
        :tag_param => /(\d*)/,
        :tag_param_tokens => [{:token => :size}]},
      :color => {
        :html_open => '<span style="color: %color%;">', :html_close => '</span>',
        :description => 'Change the color of the text',
        :example => '[color=red]This is red[/color]',
        :allow_tag_param => true, :allow_tag_param_between => false,
        :tag_param => /(([a-z]+)|(#[0-9a-f]{6}))/i,
        :tag_param_tokens => [{:token => :color}]},
      :youtube => {
        :html_open => '<object width="400" height="325"><param name="movie" value="http://www.youtube.com/v/%between%"></param><embed src="http://www.youtube.com/v/%between%" type="application/x-shockwave-flash" width="400" height="325"></embed></object>', :html_close => '',
        :description => 'Youtube video',
        :example => '[youtube]E4Fbk52Mk1w[/youtube]',
        :only_allow => [],
        :url_varients => ["youtube.com", "youtu.be", "y2u.be"], # NOT USED
        :url_matches => [/youtube\.com.*[v]=([^&]*)/, /youtu\.be\/([^&]*)/, /y2u\.be\/([^&]*)/],
        :require_between => true},
      :vimeo => {
        :html_open => '<iframe src="http://player.vimeo.com/video/%between%?badge=0" width="500" height="281" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>', 
        :html_close => '',
        :description => 'Vimeo video',
        :example => '[vimeo]http://vimeo.com/46141955[/vimeo]',
        :only_allow => [],
        :url_matches => [/vimeo\.com\/([^&]*)/],
        :require_between => true},
      :veoh => {
        :html_open => '<object width="410" height="341" id="veohFlashPlayer" name="veohFlashPlayer"><param name="movie" value="http://www.veoh.com/swf/webplayer/WebPlayer.swf?version=AFrontend.5.7.0.1404&permalinkId=%between%&player=videodetailsembedded&videoAutoPlay=0&id=anonymous"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.veoh.com/swf/webplayer/WebPlayer.swf?version=AFrontend.5.7.0.1404&permalinkId=%between%&player=videodetailsembedded&videoAutoPlay=0&id=anonymous" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="410" height="341" id="veohFlashPlayerEmbed" name="veohFlashPlayerEmbed"></embed></object><br />',
        :html_close => '',
        :description => 'moar videos, some full length ones',
        :example => '[veoh]http://www.veoh.com/watch/v825695EXrZWRfH[/veoh]',
        :only_allow => [],
        :url_matches => [/veoh\.com\/watch\/([^&]*)/],
        :require_between => true},
      :flickr => {
        :html_open => '<object type="application/x-shockwave-flash" width="400" height="300" data="http://www.flickr.com/apps/video/stewart.swf?v=109786" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"> <param name="flashvars" value="intl_lang=en-us&photo_secret=b4d35d51bd&photo_id=%between%"></param> <param name="movie" value="http://www.flickr.com/apps/video/stewart.swf?v=109786"></param> <param name="bgcolor" value="#000000"></param> <param name="allowFullScreen" value="true"></param><embed type="application/x-shockwave-flash" src="http://www.flickr.com/apps/video/stewart.swf?v=109786" bgcolor="#000000" allowfullscreen="true" flashvars="intl_lang=en-us&photo_secret=b4d35d51bd&photo_id=%between%" height="300" width="400"></embed></object>',
        :html_close => '',
        :description => 'videos by fickr, a picture company',
        :example => '[flickr]http://www.flickr.com/photos/antimega/2397432981[/flickr]',
        :only_allow => [],
        :url_matches => [/flickr\.com\/photos\/.*\/([^&]*)/],
        :require_between => true},
      :engage_media => {
        :html_open => "<iframe src='http://www.engagemedia.org/Members/indocs/videos/%between%/embed_view' frameborder='0' width='630' height='460'></iframe>",
        :html_close => '',
        :description => 'Videos about earth and humans and stuff.  They distinctly have no cesorship which is rare.',
        :example => '[engage_media]http://www.nbcnews.com/id/3032600#52211333[/engage_media]',
        :only_allow => [],
        :url_matches => [/engagemedia\.org\/Members\/.*\/videos\/([^&]*)\/view/],
        :require_between => true},
      :media => {
        :multi_tag => true,
        :supported_tags => [
          :youtube,
          :vimeo,
          :flickr,
          :veoh,
          :engage_media
        ]
      }
    }

    def self.tag_list
      @@tags
    end
  end
end
