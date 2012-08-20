# coding: utf-8

module ActiveExport
  class Xml < ::ActiveExport::Base
    # @return [String] XML style string
    def export(data)
      str = ''
      str << source[:xml_format][:header]
      [].tap {|o| export_data(data, o)}.inject([]) do |result, f|
        result << {}.tap{|o|
          self.label_keys.each_with_index {|k, i| o[k] = f[i] }
        }
      end.each do |f|
        str << binding(f)
      end
      str << source[:xml_format][:footer]
      str
    end

    def export_file(data, filename)
      File.atomic_write(filename.to_s) do |file|
        file.write export(data)
      end
    end

    protected

    # @params [Hash] values Format: { label_1: value_1, ... }
    def binding(values)
      result_string = binding_source.dup
      values.each_pair do |k,v|
        result_string.gsub!("%%#{k}%%", v)
      end
      result_string
    end

    def binding_source
      @xml_body ||= source[:xml_format][:body]
    end
  end
end