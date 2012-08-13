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

  describe ".translate" do
    before { @default_locale = I18n.locale }
    after {
      I18n.locale = @default_locale
      I18n.backend.reload!
    }

    let(:i18n_key) { 'author.name' }
    context "active_export" do
      before do
        I18n.backend.store_translations :en, active_export: {
          default: {
            book: {
              author: {
                name: 'author_name'
              }
            }
          }
        }
      end

      it "should return 'author_name'" do
        I18n.locale = :en
        ActiveExport::Base.translate('author.name', [:default, :book]).should == 'author_name'
      end
    end

    context "activerecord" do
      before do
        I18n.backend.store_translations :en, activerecord: { attributes: { author: { name: 'AuthorName' } } }
      end

      it "should return 'AuthorName" do
        I18n.locale = :en
        ActiveExport::Base.translate('author.name', [:default, :book]).should == 'AuthorName'
      end
    end

    context "activemodel" do
      before do
        I18n.backend.store_translations :en, activemodel: { attributes: { author: { name: 'Author_Name' } } }
      end

      it "should return 'Author_Name" do
        I18n.locale = :en
        ActiveExport::Base.translate('author.name').should == 'Author_Name'
      end
    end

    context "not found" do
      it "should return 'Author_Name" do
        I18n.locale = :en
        ActiveExport::Base.translate('author.name').should == 'Author name'
      end
    end
  end
end