# coding: utf-8

require 'spec_helper'

describe ActiveExport::Xml do
  before {
    ActiveExport.configure do |config|
      config.sources = { xml: fixture_file('xml.yml') }
    end
  }

  let(:author_1) { Author.create!(name: 'author_1') }
  let(:author_2) { Author.create!(name: 'author_2') }
  let!(:book_1) { Book.create!(name: 'book_1', author: author_1, price: 58) }
  let!(:book_2) { Book.create!(name: 'book_2', author: author_2, price: 38) }

  let(:expect_string) {
    <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<records>
<book>
  <name>book_1</name>
  <author_name>author_1</author_name>
  <price>63.51</price>
</book>
<book>
  <name>book_2</name>
  <author_name>author_2</author_name>
  <price>41.61</price>
</book>
</records>
    EOS
  }
  describe ".export" do
    subject { ActiveExport::Xml.export(Book.scoped, :xml, :book_1) }
    it { should == expect_string }
  end

  describe ".export_file" do
    let(:xml_file) { Rails.root.join('tmp', 'test.xml') }
    before {
      FileUtils.rm yaml_file if FileTest.exist?(xml_file)
      ActiveExport::Xml.export_file(Book.scoped, :xml, :book_1, xml_file)
    }
    after {
      FileUtils.rm xml_file if FileTest.exist?(xml_file)
    }
    it { File.read(xml_file).should == expect_string }
  end
end