# coding: utf-8

require 'yaml'

module ActiveExport
  class Yaml < ::ActiveExport::Base
    # @return [String] YAML style string
    # @memo output format(i want)
    # - 
    #  - label: value
    #  - label: value
    def export(data)
      [].tap {|o|
        export_data(data, o)
      }.to_yaml
    end

    def export_file(data, filename)
      File.atomic_write(filename.to_s) do |file|
        file.write export(data)
      end
    end
  end
end