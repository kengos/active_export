# coding: utf-8

require 'spec_helper'

describe ActiveExport::Csv do
  describe ".export" do
    let(:author_1) { Author.create!(name: 'author_1') }
    let(:author_2) { Author.create!(name: 'author_2') }
    let!(:book_1) { Book.create!(name: 'book_1', author: author_1, price: 1000) }
    let!(:book_2) { Book.create!(name: 'book_2', author: author_2, price: 2000) }

    before {
      ActiveExport.configure do |config|
        config.sources = { :default => fixture_file('csv_1.yml') }
      end
    }

    subject { ActiveExport::Csv.export(Book.order('id DESC').all, :default, :author) }
    it {
      should == <<-EOS
"Book name","Author name","Book price"
"book_2","author_2","2000"
"book_1","author_1","1000"
      EOS
    }
  end
end