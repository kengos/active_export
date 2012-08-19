# ActiveExport

ActiveExport generate from ActiveRecord or others to CSV String or CSV file.

You can write the logic of generating CSV to a YAML file.

Another Support:

  * csv label adapt i18n.
  * when the value of csv data is null or blank or true or false, change another label<br>
  ex) nil to '', blank to 'empty', true to 'Yes', false to 'No'<br>

Example:

````ruby
ActiveExport::Csv.export(Book.scoped, source_name, namespace)
````

YAML file
````
[namespace]:
  label_prefix: 'book'
  methods:
    - name
    - author.name
    - price: '(price * 1.095).ceil.to_i'
    - created_at.strftime('%Y-%m-%d')
````

Write the same way without the ActiveExport:

````ruby
CSV.generate do |csv|
  csv << ['Title', 'Author', 'Price(in Tax)', 'Published Date']
    Book.all.each do |book|
      csv_data = []
      csv_data << book.name.blank? ? '' : book.name
      csv_data << book.author ? book.author.name : ''
      csv_data << (book.price * 1.095).ceil.to_i
      csv_data << book.created_at.blank? ? '' : book.created_at.strftime('%Y-%m-%d')
      csv << csv_data
    end
  end
end
````

## Installation

Add this line to your application's Gemfile:

    gem 'active_export'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_export

## Usage

Add initalizers `active_export.rb`

    touch config/initializers/active_export.rb

Write configuration code to `active_export.rb`

````ruby
  ActiveExportconfigure do |config|
    config.sources = { default: Rails.root.join('config', 'active_export.yml') }
    config.default_csv_optoins = { col_sep: ',', row_sep: "\n", force_quotes: true }
    # config.default_find_in_batches_options = {} # default
    # config.default_value_label_scope = [:default_value_labels] # default
    # config.always_reload = false # default
    # config.no_source_raise_error = false # default
  end
````

Create `active_export.yml` And write csv export method

    touch config/active_export.yml

Write Csv generate logic

````
[namespace_1]:
  label_prefix: 'book'
  methods:
    - row[0] method
    - row[1] method
    ...
[namespace_2]:
  label_prefix: ...
  ...
````

Call Export method

    ActiveExport::Csv.export(Book.scoped, :default, :namespace_1)
    ActiveExport::Csv.export_file(Book.scoped, :default, :namespace_1, filename)

## ActiveExport::Csv

Support 2 methods:

  * export(data, source_name, namespace, options = {}) ... Generate Csv string
  * export_file(data, source_name, namespace, filename, options = {}) ... Generate Csv file

options:

  * :eval_methods ... override export method from YAML file.
  * :label_keys ... override csv header label from YAML file.
  * :label_prefix ... override csv header label prefix from YAML file.
  * :csv_options ... Csv generate options.
  * :header ... false to not export Csv header labels.

## YAML file format

```
[namespace]:
  label_prefix: [label_prefix]
  methods:
    - [method_name]
    - [label_name]: [method_name]
    - ...
```

### I18n field priority

1. `active_export.#{source_name}.#{namespace}.(label_prefix_)#{key}`
2. `activerecord.attributes.(label_prefix.)#{key}`
3. `activemodel.attributes.(label_prefix.)#{key}`
4. `#{key.to_s.gsub(".", "_").humanize}`

ex)
<pre>
key ... author.name
label_prefix ... book
source_name ... default
namespace ... book_1

1. `active_export.default.book_1.author_name`
2. `activerecord.attributes.author.name`
3. `activemode.attributes.author.name`
4. `author_name".humanize # => Author name`
</pre>

ex2)
<pre>
key ... "name"
label_prefix ... "book"
source_name ... "default"
namespace ... "book_1"

1. `active_export.default.book_1.book_name`
2. `activerecord.attributes.book.name`
3. `activemode.attributes.book.name`
4. `book_name`.humanize # => Book name
</pre>


### methods examples

```
book:
  - "author.name" # call [instance].author.name
  - "price > 0" # call [instance].price > 0 # => true or false
  - "price.to_f / 2.0" # call [instance].price.to_f / 2.0
  - "sprintf("%#b", price)" # call sprintf("%#b", [instance].price)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
