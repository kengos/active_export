# coding: utf-8

require 'i18n'
require 'active_support'

module ActiveExport
  class Base
    class << self
      def generate_header(keys, klass, scope = [])
        result = []
        keys.each do |key|
          key = "#{klass.name.downcase}.#{key}" unless key.include? '.'
          result << translate(key, scope)
        end
        result
      end

      def generate_value(row, export_methods)
        result = []
        export_methods.each do |f|
          result << convert( (row.send(:eval, f) rescue nil) )
        end
        result
      end

      # Convert value for export string
      def convert(value)
        if value.nil?
          ''
        elsif value == true && ::ActiveExport.configuration.boolean_label.has_key?(:true)
          translate(::ActiveExport.configuration.boolean_label[:true], [:boolean_label])
        elsif value == false && ::ActiveExport.configuration.boolean_label.has_key?(:false)
          translate(::ActiveExport.configuration.boolean_label[:false], [:boolean_label])
        else
          value.to_s
        end
      end

      def translate(key, scope = [])
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
end