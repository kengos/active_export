# coding: utf-8

require 'spec_helper'

describe ActiveExport::Base do
  let(:author_1) { Author.create!(name: 'author_1') }
  let(:author_2) { Author.create!(name: 'author_2') }

  describe ".generate_value" do
    let!(:book_1) { Book.create!(name: 'book_1', author: author_1, price: 1000) }

    let(:export_methods) { %w(name author.name price) }
    subject { ActiveExport::Base.generate_value(book_1, export_methods) }
    it { should eql %w(book_1 author_1 1000) }
  end
end