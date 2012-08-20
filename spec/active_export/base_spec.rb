# coding: utf-8

require 'spec_helper'

describe ActiveExport::Base do
  before {
    ActiveExport.configure do |config|
      config.sources = { default: fixture_file('csv_1.yml') }
    end
  }

  let(:active_export) { ActiveExport::Base.new('default', 'book_2') }
  it { active_export.source_name = :default }
  it { active_export.namespace = :book_2 }
  it { active_export.config.should == ActiveExport.configuration }

  context "with options" do
    let(:active_export) { ActiveExport::Base.new('source', 'namespace', label_keys: %w(name), eval_methods: %w(price)) }
    it { active_export.label_keys == %w(name) }
    it { active_export.eval_methods == %w(price) }
  end

  it { active_export.label_keys.should == %w(name author.name price) }
  it { active_export.eval_methods.should == ['name', 'author.name', '(price * 1.095).ceil.to_i'] }
  it { active_export.label_prefix.should == 'book' }
  it { active_export.default_scope == [:default, :book_2] }

  it 'should not call build_label_keys_and_eval_methods!' do
    active_export.label_keys
    active_export.should_not_receive(:build_label_keys_and_eval_methods!)
    active_export.label_keys
    active_export.eval_methods
  end

  describe "#key_name" do
    it { active_export.key_name('hoge').should eql 'book.hoge' }
    it { active_export.key_name('author.name').should eql 'author.name' }
  end

  describe "#convert" do
    before do
      I18n.backend.store_translations :en, active_export: {
        default_value_labels: { nil: 'Error', blank: 'Blank', true: 'Yes!', false: 'No!' }
      }
    end
    it { active_export.convert(nil).should eql 'Error' }
    it { active_export.convert('').should eql 'Blank' }
    it { active_export.convert(true).should eql 'Yes!' }
    it { active_export.convert(false).should eql 'No!' }
  end

  describe "#source" do
    before {
      ActiveExport.configure do |config|
        config.sources = {  }
        config.no_source_raise_error = true
      end
      active_export.source_name = :not_found
    }
    it { expect { active_export.source }.to raise_error RuntimeError }
  end

  describe ".build_label_keys_and_eval_methods" do
    subject { ActiveExport::Base.build_label_keys_and_eval_methods(params) }

    context "String" do
      let(:params) { ["name"] }
      it { should == [%w(name), %w(name)] }
    end

    context "Hash" do
      let(:params) { [{"price"=>"price * 1.05"}] }
      it { should == [%w(price), ["price * 1.05"]] }
    end
  end

  describe "#export_data" do
    let(:csv_exporter) { ActiveExport::Base.new(:default, :book_1) }
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

  describe ".translate" do
    let(:i18n_key) { 'author.name' }
    subject { ActiveExport::Base.translate('author.name', [:default, :book]) }

    context "active_export" do
      before do
        I18n.backend.store_translations :en, active_export: {
          default: { book: { author_name: 'author_name' } }
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