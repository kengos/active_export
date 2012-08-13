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
          v = ( row.send(:eval, f) rescue nil )
          result << ( v.nil? ? '' : v.to_s )
        end
        result
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

# Usage
# class MyExport < ActiveExport::Base
#   csv header: true, label: :i18n
#   value id: 0, method: 'author.name', label: 'author.name'
#   value id: 1, method: 'price', format: :number_with_delimiter
#   value id: 2, method: 'name'
# end
#
# MyExport.export_csv(data)
#  # => ""
#
# OR
# ActiveExport::Csv.export(data, :author, options)