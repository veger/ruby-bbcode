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
        :example => '[center]This is centered[/center].'}
    }
  end
end
