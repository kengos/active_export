# ActiveExport

Export to csv from ActiveRecord or others

You do not need to write the dirty code to output the csv in your controller, model or others.

In your controller:

<pre>
def export
  CSV.generate do |csv|
    csv &gt;&gt; ['Title', 'Author', 'Price(in Tax)', 'Published Date']
    Book.all.each do |book|
      csv &gt;&gt; [book.name, (book.author.try(:name) || ''), book.price, book.created_at.strftime('%Y%m%d')]
    end
  end
end

# => ActiveExport::Csv.export(Book.all, source_file_name, namespace)
</pre>

## Installation

Add this line to your application's Gemfile:

    gem 'active_export'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_export

## Usage

Add initalizers 'active_export.rb'

<pre>
ActiveExportconfigure do |config|
  # config.sources = { default: Rails.root.join('config', 'active_export.yml') }
  # config.default_csv_optoins = { col_sep: ',', row_sep: "\n", force_quotes: true }
  # config.always_reload = true # default false
end
</pre>

Create 'active_export.yml' And write csv export method

ex)

<pre>
book:
  - 'name'
  - 'author.name'
  - 'price'
  - "created_at.strftime('%Y%m%d')"
</pre>

ActiveRecord:

<pre>
class Book &gt; ActiveRecord::Base
  belongs_to :author
end

class Author &lt; ActiveRecord::Base
end
</pre>

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

en.yml or others:

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

In your controller or others:

<pre>
ActiveExport::Csv.export(Book.all, :default, :book)
# =>
# "Title","Author","Price(in Tax)","Published Date"
# "Ruby","Bob","50","2012/08/01"
# "Java","Alice","20","2012/08/02"
</pre>

## Export method magic

<pre>
eval_methods.each do |f|
  row.send(:eval, f)
end
</pre>

'row' is a ActiveRecord(or others) instance.

'eval methods' are String Array loaded from yml file.

ex)

In config/initalizers/active_export.rb:

    sources = { default: Rails.root.join('config', 'active_export.yml') }

In active_export.yml:

    book:
      - 'name'
      - 'author.name'

Ruby Script:

````ruby
data = [Book.new(name: 'PHP', author_id: 1)]
ActiveExport::Csv(data, :default, :book)
# this line means:
#    Csv.generate do |csv|
#      data.each do |f|
#        csv << [f.name, f.author.name]
#      end
#    end
````

## YAML file setting example

<pre>
book:
  - "author.name"
  - "price > 0"
  - "price.to_f / 2.0"
  - "sprintf("%#b", price)"
</pre>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
