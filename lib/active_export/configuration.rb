# coding: utf-8

module ActiveExport
  class Configuration
    attr_accessor :sources
    attr_accessor :default_csv_options
    attr_accessor :always_reload
    attr_accessor :default_value_label_scope

    def initialize
      @sources = {}
      @default_csv_options = { col_sep: ',', row_sep: "\n", force_quotes: true }
      @always_reload = false
      @default_value_label_scope = [:default_value_labels]
    end
  end
end