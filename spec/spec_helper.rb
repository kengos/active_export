require 'rspec'
require 'tapp'
require 'rails/rails_support'
require 'factory_girl'
FactoryGirl.find_definitions

require File.expand_path(File.dirname(__FILE__) + '/../lib/active_export')

def fixture_file(filename)
  File.expand_path(File.dirname(__FILE__)) + '/fixtures/' + filename
end