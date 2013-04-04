# Configure Rails Environment
#ENV["RAILS_ENV"] = "test"

#require File.expand_path("../dummy/config/environment.rb",  __FILE__)
#require "rails/test_help"

#Rails.backtrace_cleaner.remove_silencers!

require 'ruby-bbcode'
require "test/unit"


#  This hack allows us to make all the private methods of a class public.  
class Class
  def publicize_methods
    saved_private_instance_methods = self.private_instance_methods
    self.class_eval { public(*saved_private_instance_methods) }
    yield
    self.class_eval { private(*saved_private_instance_methods) }
  end
end