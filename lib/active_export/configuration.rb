# coding: utf-8

module ActiveExport
  class Configuration
    attr_accessor :sources
    attr_accessor :default_csv_options

    def initialize
      @sources = {}
      @default_csv_options = { col_sep: ',', row_sep: "\n", write_headers: true, force_quotes: true }
    end
  end
end