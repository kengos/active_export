require "active_export/version"
require 'active_export/configuration'
require 'yaml'
require 'erb'

module ActiveExport
  autoload :Base, 'active_export/base'
  autoload :Csv, 'active_export/csv'

  class << self
    # @example
    #   ActiveExportconfigure do |config|
    #     # ActiveExport export configuration files.
    #     config.sources = { default: Rails.root.join('config', 'active_export.yml') }
    #
    #     # see CSV.new options 
    #     config.default_csv_optoins = { col_sep: ',', row_sep: "\n", force_quotes: true }
    #
    #     # if set 'true', ActiveExport no cached yml data. Every time load yml file.
    #     # if set 'false', ActiveExport cached yml data.
    #     config.always_reload = true # default false
    #
    #     # en.yml or others
    #     # en:
    #     #   active_export:
    #     #     default_value_labels:
    #     #       nil: ''
    #     #       blank: ''
    #     #       yes: 'Yes'
    #     #       no: 'No'
    #     config.default_value_labels = { nil: 'nil', blank: 'blank', true: 'yes', false: 'no' }
    #   end
    def configure
      yield configuration
    end
    
    # Accessor for ActiveExport::Configuration
    def configuration
      @configuration ||= Configuration.new
    end
    alias :config :configuration

    def [](key)
      source(key)
    end

    def clear!
      @source = {}
      true
    end

    def load!
      config.sources.each {|f| source(f) }
      true
    end

    def reload!
      clear!
      load!
    end

    def source(key)
      if @configuration.always_reload
        load!(key)
      else
        @sources ||= {}
        @sources[key] ||= load!(key)
      end
    end

    def include_source?(key)
      @configuration.sources.has_key?(key)
    end

    def load!(key)
      if include_source?(key)
        YAML.load(ERB.new(open(@configuration.sources[key]).read).result).to_hash
      else
        raise "Missing '#{key}' in sources"
      end
    end
  end
end
