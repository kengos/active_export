# coding: utf-8

require 'i18n'
require 'active_support'

module ActiveExport
  class Base
    attr_accessor :source_name, :namespace, :label_prefix, :source, :label_keys, :eval_methods, :options
    attr_reader :config
    def initialize(source_name, namespace, options = {})
      @source_name = source_name.to_sym
      @namespace = namespace.to_sym
      @config = ::ActiveExport.configuration
      @label_keys = options.has_key?(:label_keys) ? options.delete(:label_keys) : nil
      @eval_methods = options.has_key?(:eval_methods) ? options.delete(:eval_methods) : nil
      @label_prefix = options.has_key?(:label_prefix) ? options.delete(:label_prefix) : nil
      @options = options
    end

    class << self
      # Generate Csv String
      # @param [Array, ActiveRecord::Relation] data
      # @param [Symbol, String] source
      # @param [Symobl, String] namespace
      # @param [Hash] options ({})
      # @option options [Array] :eval_methods
      # @option options [Array] :label_keys
      # @option options [String] :label_prefix
      # @option options [Hash] :csv_options (see http://ruby-doc.org/stdlib-1.9.2/libdoc/csv/rdoc/CSV.html)
      # @return [String] Csv String
      def export(data, source, namespace, options = {})
        new(source, namespace, options).export(data)
      end

      # Generate Csv File
      # @param [Array, ActiveRecord::Relation] data
      # @param [Symbol, String] source YAML File alias name (see ActiveExport::Configuration#sources)
      # @param [Symbol, String] namespace YAML File namespace
      # @param [String, Filepath] filename Csv File name
      # @param [Hash] options ({}) (see .export)
      def export_file(data, source, namespace, filename, options = {})
        new(source, namespace, options).export_file(data, filename)
      end

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

    # Export data to exporter
    # @param [Array, ActiveRecord::Relation] data Export target data
    # @param [Object] Object needs to support '<<' accessor
    def export_data(data, exporter)
      if data.respond_to?(:find_in_batches) && data.respond_to?(:orders) && data.orders.blank? && data.respond_to?(:taken) && data.taken.blank?
        data.find_in_batches(find_in_batches_options) do |group|
          group.each{|f| exporter << generate_value(f) }
        end
      else
        data.each{|f| exporter << generate_value(f) }
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
      raise e if self.config.no_source_raise_error
      return {}
    end

    def translate(key, scope = nil)
      self.class.translate(key, scope || default_scope)
    end

    protected

    def generate_header
      self.label_keys.inject([]) {|result, key|
        result << translate(key_name(key))
      }
    end

    def generate_value(row)
      self.eval_methods.inject([]){|result, f|
        v = row.send(:eval, f) rescue nil
        result << convert(v)
      }
    end

    def find_in_batches_options
      self.config.default_find_in_batches_options.merge( self.options[:find_in_batches_options] || {} )
    end
  end
end