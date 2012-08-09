# coding: utf-8

require 'spec_helper'

describe ActiveExport::Base do
  let(:author_1) { Author.create!(name: 'author_1') }
  let(:author_2) { Author.create!(name: 'author_2') }

  describe ".export" do
    let!(:book_1) { Book.create!(name: 'book_1', author: author_1, price: 1000) }
    let!(:book_2) { Book.create!(name: 'book_2', author: author_2, price: 2000) }

    let(:export_methods) { %w(name author.name price) }
    subject { ActiveExport::Base.export(Book.order('id ASC').all, export_methods) }
    its(:first) { should eql %w(book_1 author_1 1000) }
    its(:last) { should eql  %w(book_2 author_2 2000) }
  end
end