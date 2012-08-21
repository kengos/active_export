# coding: utf-8

# @see http://asciicasts.com/episodes/218-making-generators-in-rails-3
module ActiveExport
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Copy ActiveExport default files"
      source_root File.expand_path('../templates', __FILE__)

      def copy_initializers
        copy_file 'config.rb', 'config/initializers/active_export.rb'
        copy_file 'default.yml', 'config/active_export/default.yml'
      end

    end
  end
end