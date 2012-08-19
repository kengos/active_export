# coding: utf-8

module ActiveExport
  class Configuration
    # YAML file list
    attr_accessor :sources
    # Default options export CSV
    attr_accessor :default_csv_options
    # Default options using `find_in_batches`
    attr_accessor :default_find_in_batches_options
    # Set true, no cached YAML file data
    attr_accessor :always_reload
    # Export data default labels when value is nil or blank or true or false
    attr_accessor :default_value_label_scope
    # Set true, if selected source file does not exists, ActiveExport raise error
    attr_accessor :no_source_raise_error

    def initialize
      @sources = {}
      @default_csv_options = { col_sep: ',', row_sep: "\n", force_quotes: true }
      @always_reload = false
      @default_value_label_scope = [:default_value_labels]
      @no_source_raise_error = false
      @default_find_in_batches_options = {}
    end
  end
end