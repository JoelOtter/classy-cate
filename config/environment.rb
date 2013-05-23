# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Tilt::CoffeeScriptTemplate.default_bare = true
ClassyCate::Application.initialize!
