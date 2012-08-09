# coding: utf-8

module ActiveExport
  class Base
    class << self
      # @param export_methods [Array]
      def export(data, export_methods, options = {})
        _optoins = { :header => true }.merge(options)
        return '' if data.size == 0
        csv_array = []
        each_method_name = data.respond_to?(:find_each) ? 'find_each' : 'each'
        data.send(each_method_name) do |row|
          csv_array << generate_value(row, export_methods)
        end
        csv_array
      end

      def generate_header(row, settings = {})
      end

      def generate_value(row, export_methods)
        result = []
        export_methods.each do |f|
          v = ( row.send(:eval, f) rescue nil )
          result << ( v.nil? ? '' : v.to_s )
        end
        result
      end
    end
  end
end