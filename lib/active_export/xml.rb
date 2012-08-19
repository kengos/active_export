# coding: utf-8

module ActiveExport
  class Xml < ::ActiveExport::Base
    def self.export(data, source, namespace, options = {})
      new(source, namespace, options).export(data)
    end

    def self.export_file(data, source, namespace, filename, options = {})
      new(source, namespace, options).export(data, filename)
    end

    def export(data)
    end

    def export_file(data, filename)
    end
  end
end