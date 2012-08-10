# coding: utf-8

module ActiveExport
  class Configuration
    attr_accessor :sources

    def initialize
      @sources = {}
    end
  end
end