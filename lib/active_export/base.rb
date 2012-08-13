# coding: utf-8

require 'i18n'
require 'active_support'

module ActiveExport
  class Base
    attr_accessor :source, :namespace, :options, :config, :eval_methods

    def initialize(source, namespace, options = {})
      @source = source
      @namespace = namespace
      @options = options
      @config = ::ActiveExport.configuration.dup
    end

    def eval_methods
      @eval_methods ||= ::ActiveExport[self.source.to_sym][self.namespace.to_s]
    rescue => e
      pp e
      return nil
    end

    # Convert value for export string
    def convert(value, options = {})
      _options = self.config.default_value_labels.merge options
      if value.nil?
        if _options[:nil]
          translate(_options[:nil], [:default_value_labels])
        else
          ''
        end
      elsif value == ''
        if _options[:blank]
          translate(_options[:blank], [:default_value_labels])
        else
          ''
        end
      elsif value == true && _options[:true]
        translate(_options[:true], [:default_value_labels])
      elsif value == false && _options[:false]
        translate(_options[:false], [:default_value_labels])
      else
        value.to_s
      end
    end

    def translate(key, scope = [])
      self.class.translate(key, scope)
    end

    def self.translate(key, scope = [])
      defaults = [
        :"active_export.#{scope.join('.')}.#{key.gsub('.', '_')}",
        :"activerecord.attributes.#{key}",
        :"activemodel.attributes.#{key}",
        key.gsub('.', '_').humanize
      ]
      I18n.translate(defaults.shift, default: defaults)
    end
  end
end