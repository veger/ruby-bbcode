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
        :domains => ["youtube.com", "youtu.be"],
        :require_between => true},
      :gvideo => {
        :html_open => '<embed id="VideoPlayback" src="http://video.google.com/googleplayer.swf?docid=%between%&hl=en" style="width:400px; height:325px;" type="application/x-shockwave-flash"></embed>', :html_close => '',
        :description => 'Google video',
        :example => '[gvideo]397259729324681206[/gvideo]',
        :only_allow => [],
        :require_between => true},
      :vimeo => {
        :html_open => '<iframe src="http://player.vimeo.com/video/46141955?badge=0" width="500" height="281" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>', 
        :html_close => '',
        :description => 'Vimeo video',
        :example => '[vimeo]http://vimeo.com/46141955[/vimeo]',
        :only_allow => [],
        :domains => ["vimeo.com"],
        :require_between => true},
        
      :media => {
        :multi_tag => true,
        :supported_tags => {
          :youtube => [/youtube.com/i]
        }
      }
    }

    def self.tag_list
      @@tags
    end
  end
end
