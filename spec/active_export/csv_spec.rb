# coding: utf-8

require 'spec_helper'

describe ActiveExport::Csv do
  before {
    @default_locale = I18n.locale
    I18n.locale = :en
  }

  after {
    I18n.backend.reload!
    I18n.locale = @default_locale
  }

  let(:csv_exporter) { ActiveExport::Csv.new(:default, :book) }

  describe ".generate_value" do
    let(:author_1) { Author.create!(name: 'author_1') }
    let!(:book_1) { Book.create!(name: 'book_1', author: author_1, price: 1000) }

    let(:export_methods) { ['name', "author.name", 'price', 'deleted_at', 'price > 0'] }
    subject { csv_exporter.generate_value(book_1, export_methods) }
    it { should eql ['book_1', 'author_1', '1000', 'Nil', 'Yes'] }
  end

  describe ".generate_header" do
    let(:keys) { %w(name author.name price) }

    subject { csv_exporter.generate_header(keys, Book, [:default, :book]) }

    context "no language file" do
      it { should eql ['Book name', 'Author name', 'Book price'] }
    end

    context "translate" do
      before do
        I18n.backend.store_translations :en, activerecord: {
          attributes: {
            book: { name: 'name', price: 'Price(in tax)' },
            author: { name: 'Author Name' }
          }
        }
        I18n.backend.store_translations :en, active_export: {
          default: {
            book: { book_name: 'Title' }
          }
        }
      end

      it { should eql ['Title', 'Author Name', 'Price(in tax)'] }
    end
  end

  describe ".export" do
    let(:author_1) { Author.create!(name: 'author_1') }
    let(:author_2) { Author.create!(name: 'author_2') }
    let!(:book_1) { Book.create!(name: 'book_1', author: author_1, price: 1000) }
    let!(:book_2) { Book.create!(name: 'book_2', author: author_2, price: 2000) }

    before {
      ActiveExport.configure do |config|
        config.sources = { default: fixture_file('csv_1.yml') }
        config.default_csv_options = { col_sep: ',', row_sep: "\n", force_quotes: true }
      end
    }

    context "no options" do
      subject { ActiveExport::Csv.export(Book.order('id DESC').all, :default, :author) }
      it {
        should == <<-EOS
"Book name","Author name","Book price"
"book_2","author_2","2000"
"book_1","author_1","1000"
        EOS
      }
    end

    context "add some options" do
      let(:csv_options) {
        { force_quotes: false, col_sep: ':'}
      }
      subject { ActiveExport::Csv.export(Book.order('id DESC').all, :default, :author, csv_options: csv_options) }
      it {
        should == <<-EOS
Book name:Author name:Book price
book_2:author_2:2000
book_1:author_1:1000
        EOS
      }
    end
  end
end