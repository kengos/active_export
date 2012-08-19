begin
  require 'tapp'
rescue Exception
end

require 'rails/rails_support'
require 'rspec'
require 'rspec/rails'

require 'factory_girl'
FactoryGirl.find_definitions

require File.expand_path(File.dirname(__FILE__) + '/../lib/active_export')

require 'database_cleaner'
DatabaseCleaner.clean_with :truncation
DatabaseCleaner.strategy = :transaction

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = false
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.before(:each) do
    DatabaseCleaner.start
    @default_locale = I18n.locale
    I18n.locale = :en
  end

  config.after(:each) do
    I18n.backend.reload!
    I18n.locale = @default_locale
    DatabaseCleaner.clean
  end
end

def fixture_file(filename)
  File.expand_path(File.dirname(__FILE__)) + '/fixtures/' + filename
end