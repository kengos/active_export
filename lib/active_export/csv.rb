# coding: utf-8

module ActiveExport
  class Csv < ::ActiveExport::Base
    # @param [Array or ActiveRecord::Relation] data
    # @param [Hash]
    # @exmaple
    #   AcriveExport::Csv.export(data, :source => :namespace)
    def self.export(data, source, namespace, options = {})
      return '' if data.length <= 0 || !(::ActiveExport.include_source?(source))
      eval_methods = ::ActiveExport[source.to_s][namespace.to_s]
      each_method_name = data.respond_to?(:find_each) ? 'find_each' : 'each'
      # 1.9.2
      CSV.generate do |csv|
        # TODO header
        data.send(each_method_name) do |f|
          csv << generate_value(f, eval_methods)
        end
      end
    end

  end
end