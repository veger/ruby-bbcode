module BBCode
  module Tags
    # tagname => tag, HTML open tag, HTML close tag, description, example
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
        :html_open => '<img src="%between%" alt="" />', :html_close => '',
        :description => 'Image',
        :example => '[img]http://www.google.com/intl/en_ALL/images/logo.gif[/img].',
        :only_allow => [],
        :require_between => true},
      :url => {
        :html_open => '<a href="%between%">%between%', :html_close => '</a>',
        :description => 'Link to another page',
        :example => '[url]http://www.google.com/[/url].',
        :only_allow => [],
        :require_between => true},
      :quote => {
        :html_open => '<div class="quote">', :html_close => '</div>',
        :description => 'Quote another person',
        :example => '[quote]BBCode is great[/quote]'
      }
    }
  end
end
