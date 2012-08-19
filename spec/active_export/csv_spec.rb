# coding: utf-8

require 'spec_helper'

describe ActiveExport::Csv do
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

    context "add csv_options" do
      let(:csv_options) {
        { force_quotes: false, col_sep: ':'}
      }
      subject { ActiveExport::Csv.export(Book.scoped, :default, :book_1, csv_options: csv_options) }
      it {
        should == <<-EOS
Book name:Author name:Book price
book_1:author_1:58
book_2:author_2:38
        EOS
      }
    end

    context "header false" do
      subject { ActiveExport::Csv.export(Book.scoped, :default, :book_1, header: false) }
      it {
        should == <<-EOS
"book_1","author_1","58"
"book_2","author_2","38"
        EOS
      }
    end

  end

  describe ".export_file" do
    let(:filename) { Rails.root.join('tmp', 'test.csv') }
    before {
      ActiveExport.configure do |config|
        config.sources = { default: fixture_file('csv_1.yml') }
        config.default_csv_options = { col_sep: ',', row_sep: "\n", force_quotes: true }
      end

      FileUtils.rm(filename) if FileTest.exist?(filename)
      ActiveExport::Csv.export_file(Book.scoped, :default, :book_1, Rails.root.join('tmp', 'test.csv'))
    }
    after {
      FileUtils.rm(filename) if FileTest.exist?(filename)
    }

    it { File.read(filename).split("\n").first.should eql %Q("Book name","Author name","Book price") }
  end

  describe "#export_data" do
    let(:csv_exporter) { ActiveExport::Csv.new(:default, :book_1) }
    let!(:book_1) { Book.create!(name: 'book_1', author: nil, price: 58) }
    let!(:book_2) { Book.create!(name: 'book_2', author: nil, price: 58) }
    let!(:book_3) { Book.create!(name: 'book_2', author: nil, price: 58) }

    it "should not call find_in_batches when has order" do
      obj = Book.order('id ASC')
      obj.should_not_receive(:find_in_batches)
      obj.should_receive(:each)
      csv_exporter.send(:export_data, obj, [])
    end


    it "should not call find_in_batches when has limit" do
      obj = Book.limit(1)
      obj.should_not_receive(:find_in_batches)
      obj.should_receive(:each)
      csv_exporter.send(:export_data, obj, [])
    end

    it "should not call find_in_batches when specified obj is not ActiveRecord::Relation" do
      obj = [Book.first]
      obj.should_not_receive(:find_in_batches)
      obj.should_receive(:each)
      csv_exporter.send(:export_data, obj, [])
    end

    it "should call find_in_batches" do
      obj = Book.scoped
      obj.should_receive(:find_in_batches).with({batch_size: 1})
      obj.should_not_receive(:each)
      csv_exporter.stub(:find_in_batches_options).and_return({batch_size: 1})
      csv_exporter.send(:export_data, obj, [])
    end
  end

  describe ".generate_value" do
    let(:author_1) { Author.create!(name: 'author_1') }
    let!(:book_1) { Book.create!(name: 'book_1', author: author_1, price: 1000) }
    let(:eval_methods) { ['name', "author.name", 'price', 'deleted_at', 'price > 0', 'price > 15000'] }
    let(:csv_exporter) { ActiveExport::Csv.new(:default, :book_1, eval_methods: eval_methods) }

    before {
      I18n.backend.store_translations :en, active_export: {
        default_value_labels: { nil: 'not found', blank: 'Blank', true: 'Yes!', false: 'No!' }
      }
    }
    subject { csv_exporter.send(:generate_value, book_1) }
    it { should eql ['book_1', 'author_1', '1000', 'not found', 'Yes!', 'No!'] }
  end

  describe ".generate_header" do
    let(:label_keys) { %w(name author.name price) }
    let(:csv_exporter) { ActiveExport::Csv.new(:default, :book_1, label_keys: label_keys, label_prefix: 'book') }

    subject { csv_exporter.send(:generate_header) }
    it { should eql ['Book name', 'Author name', 'Book price'] }

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