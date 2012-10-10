# Load the rails application
require File.expand_path('../application', __FILE__)


Dummy::Application.configure do
  # Log error messages when you accidentally call methods on nil
  config.whiny_nils = true

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr
end
           

# Initialize the rails application
Dummy::Application.initialize!
