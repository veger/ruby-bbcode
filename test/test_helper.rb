require 'simplecov'

SimpleCov.start do
  if ENV['CI']
    require 'simplecov-lcov'

    SimpleCov::Formatter::LcovFormatter.config do |c|
      c.report_with_single_file = true
      c.single_report_path = 'coverage/lcov.info'
    end

    formatter SimpleCov::Formatter::LcovFormatter
  end

  add_filter "/test/"
end

require 'ruby-bbcode'
require 'minitest/autorun'

# This hack allows us to make all the private methods of a class public.
class Class
  def publicize_methods
    saved_private_instance_methods = private_instance_methods
    class_eval { public(*saved_private_instance_methods) }
    yield
    class_eval { private(*saved_private_instance_methods) }
  end
end

# This is for measuring memory usage...
def get_current_memory_usage
  `ps -o rss= -p #{Process.pid}`.to_i
end
