# coding: utf-8

module ActiveExport
  class Csv < Base
    class << self
      # @param [Array or ActiveRecord::Relation] data
      # @param [Hash]
      # @exmaple
      #   AcriveExport::Csv.export(data, :source => :namespace)
      def export(data, settings, options = {})

      end

      def setting_parser(settings)
      end
    end
  end
end