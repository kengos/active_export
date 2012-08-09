# coding: utf-8

module ActiveExport
  module Csv
    def self.method_missing(method_id, *args)
      super
    end
  end
end