# coding: utf-8

module ActiveExport
  class Csv
    class << self
      # @param [Array or ActiveRecord::Relation] data
      # @param [Hash]
      # @exmaple
      #   AcriveExport::Csv.export(data, :source => :namespace)
      def export(data, settings, options = {})
        _optoins = { :header => true }.merge(options)
        return '' if data.size == 0
        header_keys = data.first.attributes.keys
        csv_array = []
        each_method_name = data.respond_to?(:find_each) ? 'find_each' : 'each'
        data.send(each_method_name) do |row|
          csv_array << row.attributes.values
        end
        csv_array
      end

      def setting_parser(settings)
      end
    end
  end
end