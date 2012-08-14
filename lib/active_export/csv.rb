# coding: utf-8

require 'csv'

module ActiveExport
  class Csv < ::ActiveExport::Base
    # @param [Array, ActiveRecord::Relation] data
    # @param [Symbol, String] source
    # @param [Symobl, String] namespace
    # @param [Hash] options ({})
    # @option options [Hash] :methods
    # @option options [Hash] :csv_options (see http://ruby-doc.org/stdlib-1.9.2/libdoc/csv/rdoc/CSV.html)
    # @option options [Hash] :convert_options
    # @exmaple
    #   AcriveExport::Csv.export(data, :source, :namespace)
    def self.export(data, source, namespace, options = {})
      new(source, namespace, options).export(data, options)
    end

    def export(data, options = {})
      return '' if data.length <= 0 && eval_methods.nil?
      csv_options = self.config.default_csv_options.merge( options[:csv_options] || {} )

      each_method_name = data.respond_to?(:find_each) ? 'find_each' : 'each'
      # 1.9.2
      CSV.generate(csv_options) do |csv|
        csv << generate_header
        data.send(each_method_name) do |f|
          csv << generate_value(f)
        end
      end
    end

    def generate_header
      self.label_keys.inject([]) {|result, key|
        result << translate(key_name(key))
      }
    end

    def generate_value(row)
      self.eval_methods.inject([]){|result, f|
        v = row.send(:eval, f) rescue nil
        result << convert(v)
      }
    end
  end
end