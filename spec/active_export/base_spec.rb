# coding: utf-8

require 'spec_helper'

describe ActiveExport::Base do
  before {
    @default_locale = I18n.locale
    I18n.locale = :en
  }

  after {
    I18n.backend.reload!
    I18n.locale = @default_locale
  }

  describe ".convert" do
    context "boolean value" do
      before do
        I18n.backend.store_translations :en, active_export: {
          default_value_labels: { nil: 'Error', blank: 'Blank', yes: 'Yes!', no: 'No!' }
        }
      end
      let(:base_obj) { ActiveExport::Base.new(:source, :namespace) }
      it { base_obj.convert(nil).should eql 'Error' }
      it { base_obj.convert('').should eql 'Blank' }
      it { base_obj.convert(true).should eql 'Yes!' }
      it { base_obj.convert(false).should eql 'No!' }
    end
  end

  describe ".translate" do
    let(:i18n_key) { 'author.name' }
    subject { ActiveExport::Base.translate('author.name', [:default, :book]) }

    context "active_export" do
      before do
        I18n.backend.store_translations :en, active_export: {
          default: {
            book: { author_name: 'author_name' }
          }
        }
      end
      it { should == 'author_name' }
    end

    context "activerecord" do
      before do
        I18n.backend.store_translations :en, activerecord: {
          attributes: { author: { name: 'AuthorName' } }
        }
      end
      it { should == 'AuthorName' }
    end

    context "activemodel" do
      before do
        I18n.backend.store_translations :en, activemodel: {
          attributes: { author: { name: 'Author_Name' } }
        }
      end
      it { should == 'Author_Name' }
    end

    context "not found" do
      it { should == 'Author name' }
    end
  end
end