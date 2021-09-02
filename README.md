# Ruby-BBCode

[![gem version](https://badge.fury.io/rb/ruby-bbcode.svg)](https://badge.fury.io/rb/ruby-bbcode) [![Code Coverage](https://coveralls.io/repos/github/veger/ruby-bbcode/badge.svg?branch=master)](https://coveralls.io/github/veger/ruby-bbcode?branch=master)

This gem adds support for [BBCode](http:/www.bbcode.org/) to Ruby. The BBCode is parsed by a parser before converted to HTML, allowing to convert nested BBCode tags in strings to their correct HTML equivalent. The parser also checks whether the BBCode is valid and gives errors for incorrect BBCode texts.
Additionally, annotations can be added to the BBCode string the showing errors that are present, assuming there are any errors.

The parser recognizes all [official tags](http://www.bbcode.org/reference.php) and allows to easily extend this set with custom tags.

## Examples

`bbcode_to_html` can be used to convert a BBCode string to HTML:

```ruby
'This is [b]bold[/b] and this is [i]italic[/i].'.bbcode_to_html
 => 'This is <strong>bold</strong> and this is <em>italic</em>.'
 ```

`bbcode_show_errors` can be used to convert a BBCode to BBCode annotated with errors (assuming the original BBCode did contain errors):

```ruby
'[img=no_dimensions_here]image.png[/img]'.bbcode_show_errors
 => '<span class=\'bbcode_error\' data-bbcode-errors=\'["The image parameters \'no_dimensions_here\' are incorrect, \'<width>x<height>\' excepted"]\'>[img]</span>image.png[/img]'
 ```

These HTML attributes containing the JSON representation of the errors can be used to inform the user about the problems.
The following JavaScript/jQuery example makes use of the [Bootstrap tooltips plugin](http://getbootstrap.com/javascript/#tooltips) to show the errors in tooltip popups:
```javascript
$(".bbcode_error").tooltip({
  title: function() {
    var errors = JSON.parse($(this).attr('data-bbcode-errors'));
    return errors.join("\n");
  }
});
```

## Installing

Add the following line to the Gemfile of your application:
```ruby
gem 'ruby-bbcode'
```

Or to use the source code from the repository:
```ruby
gem 'ruby-bbcode', :git => 'git://github.com/veger/ruby-bbcode.git'
```

Run
```shell
bundle install
```

And Ruby-BBCode is available in your application.

_Note_: Do not forget to restart your server!

## Acknowledgements

A big thanks to [@TheNotary](https://github.com/TheNotary) for all contributions he made to this project!

Some of the ideas and the tests came from [bb-ruby](https://github.com/cpjolicoeur/bb-ruby) of Craig P Jolicoeur.

## License

MIT License. See the included [MIT-LICENCE](MIT-LICENSE) file.
