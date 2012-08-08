# coding: utf-8

require 'rails'
require 'active_record'
require 'action_controller/railtie'

module ActiveExport
  class Application < Rails::Application
    config.generators do |g|
      g.orm             :active_record
      g.test_framework  :rspec, fixture: false
    end
    config.active_support.deprecation = :notify
  end
end
ActiveExport::Application.initialize!

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

support_path = File.expand_path(File.dirname(__FILE__))
require support_path + '/schema'

Dir["#{support_path}/model/**/*.rb"].each {|f| require f }