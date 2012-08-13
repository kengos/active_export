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

|_id_|_name_|_author_id_|_price_|_created_at_|
|_1_|_Ruby_|_1_|_50_|_2012/08/01 00:00:00 UTC_|
|_2_|_Java_|_2_|_30_|_2012/08/02 00:00:00 UTC_|

Author records:

|_id_|_name_|
|_1_|_Bob_|
|_2_|_Alice_|

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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
