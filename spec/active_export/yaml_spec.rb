# coding: utf-8

require 'spec_helper'

describe ActiveExport::Yaml do
  before {
    ActiveExport.configure do |config|
      config.sources = { default: fixture_file('csv_1.yml') }
    end
  }

  describe ".export" do
    let(:author_1) { Author.create!(name: 'author_1') }
    let(:author_2) { Author.create!(name: 'author_2') }
    let!(:book_1) { Book.create!(name: 'book_1', author: author_1, price: 58) }
    let!(:book_2) { Book.create!(name: 'book_2', author: author_2, price: 38) }

    let(:yaml_string) { ActiveExport::Yaml.export(Book.order('id DESC').all, :default, :book_2) }
    subject { YAML.load(yaml_string) }
    its([0]) { should == ["book_2", "author_2", "42"] }
    its([1]) { should == ["book_1", "author_1", "64"] }
  end

  describe ".export_file" do
    let(:author_1) { Author.create!(name: 'author_1') }
    let(:author_2) { Author.create!(name: 'author_2') }
    let!(:book_1) { Book.create!(name: 'book_1', author: author_1, price: 58) }
    let!(:book_2) { Book.create!(name: 'book_2', author: author_2, price: 38) }
    let(:yaml_file) { Rails.root.join('tmp', 'test.yml') }
    before {
      FileUtils.rm yaml_file if FileTest.exist?(yaml_file)
      ActiveExport::Yaml.export_file(Book.scoped, :default, :book_2, yaml_file)
    }
    after {
      FileUtils.rm yaml_file if FileTest.exist?(yaml_file)
    }
    subject { YAML.load(File.read(yaml_file)) }
    its([0]) { should == ["book_1", "author_1", "64"] }
    its([1]) { should == ["book_2", "author_2", "42"] }
  end
end