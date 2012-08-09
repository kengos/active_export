# coding: utf-8

module ActiveExport
  module Csv
    class Default
      def self.export(data, options = {})
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
    end
  end
end

# Usage

# ActiveExport::Csv.(export_setting_name)(data, options)