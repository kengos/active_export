# coding: utf-8

require 'csv'

module ActiveExport
  class Csv < ::ActiveExport::Base
    def export(data)
      CSV.generate(csv_options) do |csv|
        csv << generate_header if header?
        export_data(data, csv)
      end
    end

    def export_file(data, filename)
      File.atomic_write(filename.to_s) do |file|
        CSV.open(file, "wb", csv_options) do |csv|
          csv << generate_header if header?
          export_data(data, csv)
        end
      end
      filename
    end

    protected

    def csv_options
      self.config.default_csv_options.merge( self.options[:csv_options] || {} )
    end

    def header?
      { header: true }.merge(self.options)[:header]
    end
  end
end