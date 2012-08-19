# coding: utf-8

require 'csv'

module ActiveExport
  class Csv < ::ActiveExport::Base
    # Generate Csv String
    # @param [Array, ActiveRecord::Relation] data
    # @param [Symbol, String] source
    # @param [Symobl, String] namespace
    # @param [Hash] options ({})
    # @option options [Array] :eval_methods
    # @option options [Array] :label_keys
    # @option options [String] :label_prefix
    # @option options [Hash] :csv_options (see http://ruby-doc.org/stdlib-1.9.2/libdoc/csv/rdoc/CSV.html)
    # @return [String] Csv String
    # @exmaple
    #   AcriveExport::Csv.export(data, :source, :namespace)
    def self.export(data, source, namespace, options = {})
      new(source, namespace, options).export(data)
    end

    # Generate Csv File
    # @param [Array, ActiveRecord::Relation] data
    # @param [Symbol, String] source YAML File alias name (see ActiveExport::Configuration#sources)
    # @param [Symbol, String] namespace YAML File namespace
    # @param [String, Filepath] filename Csv File name
    # @param [Hash] options ({}) (see .export)
    def self.export_file(data, source, namespace, filename, options = {})
      new(source, namespace, options).export_file(data, filename)
    end

    def export(data)
      CSV.generate(csv_options) do |csv|
        csv << generate_header if header?
        export_data(data, csv)
      end
    end

    def export_file(data, filename)
      File.atomic_write(filename) do |file|
        CSV.open(file, "wb", csv_options) do |csv|
          csv << generate_header if header?
          export_data(data, csv)
        end
      end
      filename
    end

    # Export data to exporter
    # @param [Array, ActiveRecord::Relation] data Export target data
    # @param [CSV, Array, String] exporter CSV class or Array class, or String class (should support '<<' accessor)
    def export_data(data, exporter)
      if data.respond_to?(:find_in_batches) && data.respond_to?(:orders) && data.orders.blank? && data.respond_to?(:taken) && data.taken.blank?
        data.find_in_batches(find_in_batches_options) do |group|
          group.each{|f| exporter << generate_value(f) }
        end
      else
        data.each{|f| exporter << generate_value(f) }
      end
    end

    protected
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

    def find_in_batches_options
      self.config.default_find_in_batches_options.merge( self.options[:find_in_batches_options] || {} )
    end

    def csv_options
      self.config.default_csv_options.merge( self.options[:csv_options] || {} )
    end

    def header?
      { header: true }.merge(self.options)[:header]
    end
  end
end