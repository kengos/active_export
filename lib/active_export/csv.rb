# coding: utf-8

require 'csv'

module ActiveExport
  class Csv < ::ActiveExport::Base
    def export(data)
      CSV.generate(csv_options) do |csv|
        csv << generate_header if header?
        export_data(data, csv)
      end
    end

    def export_file(data, filename)
      File.atomic_write(filename.to_s) do |file|
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