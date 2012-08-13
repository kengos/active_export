# coding: utf-8

require 'csv'

module ActiveExport
  class Csv < ::ActiveExport::Base
    # @param [Array, ActiveRecord::Relation] data
    # @param [Symbol, String] source
    # @param [Symobl, String] namespace
    # @param [Hash] options ({})
    # @option options (see http://ruby-doc.org/stdlib-1.9.2/libdoc/csv/rdoc/CSV.html)
    # @exmaple
    #   AcriveExport::Csv.export(data, :source, :namespace)
    # @todo refactoring
    def self.export(data, source, namespace, options = {})
      return '' if data.length <= 0 
      return '' unless ::ActiveExport.include_source?(source)
      eval_methods = ::ActiveExport[source.to_sym][namespace.to_s]
      return '' unless eval_methods

      each_method_name = data.respond_to?(:find_each) ? 'find_each' : 'each'
      _options = ::ActiveExport.configuration.default_csv_options.merge options
      # 1.9.2
      CSV.generate(_options) do |csv|
        csv << generate_header(eval_methods, data.first.class, [source, namespace])
        data.send(each_method_name) do |f|
          csv << generate_value(f, eval_methods)
        end
      end
    end
  end
end