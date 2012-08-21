# coding: utf-8

ActiveExport.configure do |config|
  # ActiveExport export configuration files.
  config.sources = {
    default: Rails.root.join('config', 'active_export', 'default.yml')
    # xml: Rails.root.join('config', 'active_export', 'xml.yml')
  }

  # @see CSV.new options 
  #config.default_csv_optoins = { col_sep: ',', row_sep: "\n", force_quotes: true }

  # @see http://api.rubyonrails.org/classes/ActiveRecord/Batches.html#method-i-find_in_batches
  #default_find_in_batches_options = {} # default

  # Value where the result is set if null or blank or true, false
  # loading i18n label from active_export.default_value_labels[:nil or :blank or :true or :false]
  #default_value_label_scope = [:default_value_labels]

  # true ... ActiveExport no cached yml data. Every time load yml file.
  # false ... ActiveExport cached yml data.
  #config.always_reload = false # default

  # true ... not found sources[:source_name] to raise error
  #config.no_source_raise_error = false # default
end