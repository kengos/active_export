source 'https://rubygems.org'

# Specify your gem's dependencies in active_export.gemspec
gemspec

gem 'rails', ">= #{ENV['RAILS'] || '3.0.0'}"

group :development, :test do
  gem 'rake',           '~> 0.9.2.2', :require => false

  gem 'yard'
  gem 'rdiscount'

  gem 'tapp'

  gem 'sqlite3'
  gem 'rspec-rails'
  gem 'guard'
  gem 'guard-rspec'
  gem 'fuubar'

  gem 'libnotify', :require => false
  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'growl', :require => false
end