# coding: utf-8

module ActiveExport
  class Xml < ::ActiveExport::Base
    # @return [String] XML style string
    # @memo yaml format
    # - namespace:
    #   label_prefix: 'book'
    #   methods:
    #     - name
    #     - author.name
    #     - price: price * 1.095
    #    xml_format:
    #      encoding: 'UTF8'
    #      header: |
    #<?xml version="1.0" encoding="UTF-8"?>
    #<records>
    #      footer: |
    #</records>
    #      body: |
    #  <book>
    #    <name>%%name%%</name>
    #    <author_name>%%author_name%%</author_name>
    #    <price>%%price%%</price>
    #  </book>
    #  
    def export(data)
      # TODO
    end

    def export_file(data, filename)
      # TODO
    end
  end
end