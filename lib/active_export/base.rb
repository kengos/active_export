# coding: utf-8

require 'i18n'
require 'active_support'

module ActiveExport
  class Base
    attr_accessor :source_name, :namespace, :label_prefix, :source, :label_keys, :eval_methods
    attr_reader :config
    def initialize(source_name, namespace, options = {})
      @source_name = source_name.to_sym
      @namespace = namespace.to_sym
      @config = ::ActiveExport.configuration
      @label_keys = options.has_key?(:label_keys) ? options[:label_keys] : nil
      @eval_methods = options.has_key?(:eval_methods) ? options[:eval_methods] : nil
      @label_prefix = options.has_key?(:label_prefix) ? options[:label_prefix] : nil
    end

    class << self
      def translate(key, scope = [])
        defaults = [
          :"active_export.#{scope.join('.')}.#{key.to_s.gsub('.', '_')}",
          :"activerecord.attributes.#{key}",
          :"activemodel.attributes.#{key}",
          key.to_s.gsub('.', '_').humanize
        ]
        I18n.translate(defaults.shift, default: defaults)
      end

      # @param [Array] methods
      # @return [Array]
      def build_label_keys_and_eval_methods(methods)
        label_keys = []
        eval_methods = []
        methods.each do |f|
          if f.is_a?(Hash)
            label_keys << f.keys.first
            eval_methods << f.values.first
          else
            label_keys << f
            eval_methods << f
          end
        end
        return label_keys, eval_methods
      end
    end

    # Convert value for export string
    # @todo refactor me
    def convert(value)
      if value.nil?
        translate(:nil, config.default_value_label_scope)
      elsif value == ''
        translate(:blank, config.default_value_label_scope)
      elsif value == true
        translate(:true, config.default_value_label_scope)
      elsif value == false
        translate(:false, config.default_value_label_scope)
      else
        value.to_s
      end
    end

    def label_keys
      build_label_keys_and_eval_methods! unless @label_keys
      @label_keys
    end

    def eval_methods
      build_label_keys_and_eval_methods! unless @eval_methods
      @eval_methods
    end

    def label_prefix
      @label_prefix ||= source[:label_prefix]
    end

    def default_scope
      [self.source_name, self.namespace]
    end

    def key_name(key)
      key.to_s.include?(".") ? key.to_s : "#{label_prefix}.#{key}"
    end

    def build_label_keys_and_eval_methods!
      @label_keys, @eval_methods = self.class.build_label_keys_and_eval_methods(source[:methods])
    end

    def source
      @source ||= ::ActiveExport[self.source_name][self.namespace]
    rescue => e
      # TODO config.no_source_raise_error = true
      return nil
    end

    def translate(key, scope = nil)
      self.class.translate(key, scope || default_scope)
    end
  end
end