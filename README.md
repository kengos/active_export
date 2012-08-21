# ActiveExport

[![Build Status](https://secure.travis-ci.org/kengos/active_export.png?branch=master)](http://travis-ci.org/kengos/active_export)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/kengos/active_export)

ActiveExport generate CSV/XML/YAML String or CSV/XML/YAML file.

You can write the logic of generating csv or xml, yaml to a YAML file.

Another Support:

  * csv label adapt i18n.
  * when the value of csv data is null or blank or true or false, change another label<br>
  ex) nil to '', blank to 'empty', true to 'Yes', false to 'No'<br>

## Installation

Add this line to your application's Gemfile:

    gem 'active_export'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_export

Generate the config initializer file and `default.yml`

    $ rails g active_export:install

## Example

````ruby
ActiveExport::Csv.export(Book.scoped, source_name, namespace)
# => csv string
# "Title","AuthorName","Price(in tax)","Published"
# "Ruby","Bob","28","2012-08-01"
# "Rails","Alice","18","2012-07-01"
````

  Price(in tax) `28` is (book.price * 1.095).ceil.to_i result.

YAML file
<pre>
namespace:
  label_prefix: 'book'
  methods:
    - name
    - author.name
    - price: '(price * 1.095).ceil.to_i'
    - created_at.strftime('%Y-%m-%d')
</pre>

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

## Usage

```ruby
# Exporting Csv String
ActiveExport::Csv.export(Book.scoped, source_name, namespace)

# Exporting Csv File
ActiveExport::Csv.export_file(Book.scoped, source_name, namespace, filename)

# Exporting Xml String
ActiveExport::Xml.export(Book.scoped, source_name, namespace)

# Exporting Xml File
ActiveExport::Xml.export_file(Book.scoped, source_name, namespace, filename)

# Exporting Yaml String
ActiveExport::Yaml.export(Book.scoped, source_name, namespace)

# Exporting Yaml File
ActiveExport::Yaml.export_file(Book.scoped, source_name, namespace, filename)
```

## ActiveExport::Csv

Support 2 methods:

  * `export(data, source_name, namespace, options = {})` ... Generate Csv string
  * `export_file(data, source_name, namespace, filename, options = {})` ... Generate Csv file

options:

  * `:eval_methods` ... override export method from YAML file.
  * `:label_keys` ... override csv header label from YAML file.
  * `:label_prefix` ... override csv header label prefix from YAML file.
  * `:csv_options` ... Csv generate options.
  * `:header` ... false to not export Csv header labels.

features:

  * Support encoding

## ActiveExport::Xml

Support 2 methods:

  * `ActiveExport::Xml.export(Book.scoped, source_name, namespace)` ... Generate Xml string
  * `ActiveExport::Xml.export_file(Book.scoped, source_name, namespace, filename)` ... Generate Xml file

options:

  * TODO

features:

  * Support encoding

## ActiveExport::Yaml

Support 2 methods:

  * `ActiveExport::Yaml.export(Book.scoped, source_name, namespace)` ... Generate Yaml string
  * `ActiveExport::Yaml.export_file(Book.scoped, source_name, namespace, filename)` ... Generate Yaml file

options:

  * TODO

features:

  * exporting i18n labels

## YAML file format

<pre>
namespace:
  label_prefix: label_prefix
  methods:
    - method_name
    - label_name: method_name
  # If using Xml export
  xml_format:
    encoding: 'UTF-8'
    header: |
      <?xml version="1.0" encoding="UTF-8"?>
      <records>
    footer: |
      </records>
    body: |
      <record>
        <name>%%label_name%%</name>
      </record>

namespace_2:
  label_prefix: ...
  ...
````
</pre>

### xml_format:

TODO

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
