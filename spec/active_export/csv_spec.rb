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

  describe ".export" do
    let(:author_1) { Author.create!(name: 'author_1') }
    let(:author_2) { Author.create!(name: 'author_2') }
    let!(:book_1) { Book.create!(name: 'book_1', author: author_1, price: 58) }
    let!(:book_2) { Book.create!(name: 'book_2', author: author_2, price: 38) }

    before {
      ActiveExport.configure do |config|
        config.sources = { default: fixture_file('csv_1.yml') }
        config.default_csv_options = { col_sep: ',', row_sep: "\n", force_quotes: true }
      end
    }

    context "no options" do
      subject { ActiveExport::Csv.export(Book.order('id DESC').all, :default, :book_2) }
      it {
        should == <<-EOS
"Book name","Author name","Book price"
"book_2","author_2","42"
"book_1","author_1","64"
        EOS
      }
    end

    context "add some options" do
      let(:csv_options) {
        { force_quotes: false, col_sep: ':'}
      }
      subject { ActiveExport::Csv.export(Book.order('id DESC').all, :default, :book_1, csv_options: csv_options) }
      it {
        should == <<-EOS
Book name:Author name:Book price
book_2:author_2:38
book_1:author_1:58
        EOS
      }
    end
  end

  describe ".generate_value" do
    let(:author_1) { Author.create!(name: 'author_1') }
    let!(:book_1) { Book.create!(name: 'book_1', author: author_1, price: 1000) }
    let(:eval_methods) { ['name', "author.name", 'price', 'deleted_at', 'price > 0', 'price > 15000'] }
    let(:csv_exporter) { ActiveExport::Csv.new(:default, :book_1, eval_methods: eval_methods.tapp) }

    before {
      I18n.backend.store_translations :en, active_export: {
        default_value_labels: { nil: 'not found', blank: 'Blank', true: 'Yes!', false: 'No!' }
      }
    }
    subject { csv_exporter.generate_value(book_1) }
    it { should eql ['book_1', 'author_1', '1000', 'not found', 'Yes!', 'No!'] }
  end

  describe ".generate_header" do
    let(:label_keys) { %w(name author.name price) }
    let(:csv_exporter) { ActiveExport::Csv.new(:default, :book_1, label_keys: label_keys, label_prefix: 'book') }

    subject { csv_exporter.generate_header }

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
            book_1: { book_name: 'Title' }
          }
        }
      end

      it { should eql ['Title', 'Author Name', 'Price(in tax)'] }
    end
  end
end