# ActiveExport

Export to csv from ActiveRecord or others

You do not need to write the dirty code to output the csv in your controller, model or others.

In your controller:

````ruby
ActiveExport::Csv.export(Book.all, source_name, namespace)

# it means
CSV.generate do |csv|
  csv << ['Title', 'Author', 'Price(in Tax)', 'Published Date']
    Book.all.each do |book|
      csv << [book.name, (book.author.try(:name) || ''), book.price, book.created_at.strftime('%Y%m%d')]
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

Create `active_export.yml` And write csv export method

[YAML file format][yaml-file-format]

Use `ActiveExport::Csv.export(data, source_name, namespace)` in your controller or others.

## Example

ActiveRecord:

````ruby
class Book < ActiveRecord::Base
  belongs_to :author
end

class Author < ActiveRecord::Base
end
````

Book records:

| id | name | author_id | price | created_at |
|:--:|:----:|:---------:|:-----:|:----------:|
|  1 | Ruby |         1 |    50 | 2012/08/01 00:00:00 UTC |
|  2 | Java |         2 |    30 | 2012/08/02 00:00:00 UTC |

Author records:

| id |  name |
|:--:|:-----:|
|  1 |   Bob |
|  2 | Alice |

`en.yml`:

<pre>
activerecord:
  attributes:
    book:
      name: 'Title'
      price: 'Price(in Tax)'
      created_at: 'Published Date'
    author:
      name: 'Author'
</pre>

`config/initializers/active_export.rb`:

````ruby
ActiveExportconfigure do |config|
  config.sources = { default: Rails.root.join('config', 'active_export.yml') }
  ## option fields
  # config.default_csv_optoins = { col_sep: ',', row_sep: "\n", force_quotes: true }
  # config.always_reload = false # default
  # config.no_source_raise_error = false # default
end
````

`config/active_export.yml`:

````
book:
  label_prefix: 'book'
  methods:
    - name
    - author.name
    - price
    - created_at: creaetd_at.strftime('%Y/%m/%d')
````

In your controller or others:

````ruby
ActiveExport::Csv.export(Book.all, :default, :book)
# => CSV string
# "Title","Author","Price(in Tax)","Published Date"
# "Ruby","Bob","50","2012/08/01"
# "Java","Alice","20","2012/08/02"
````

## YAML file format

```
[namespace]:
  label_prefix: [label_prefix]
  methods:
    - [method_name]
    - [label_name]: [method_name]
    - ...
```

### Method_name examples

```
book:
  - "author.name" # call [instance].author.name
  - "price > 0" # call [instance].price > 0 # => true or false
  - "price.to_f / 2.0" # call [instance].price.to_f / 2.0
  - "sprintf("%#b", price)" # call sprintf("%#b", [instance].price)
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

1. "active_export.default.book_1.book_name"
2. "activerecord.attributes.book.name"
3. "activemode.attributes.book.name"
4. "book_name".humanize # => Book name
</pre>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
