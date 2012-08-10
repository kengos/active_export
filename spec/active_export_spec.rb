# coding: utf-8

require 'spec_helper'

describe ActiveExport do
  before {
    ActiveExport.configure do |config|
      config.sources = { :default => fixture_file('csv_1.yml') }
    end
  }
  it 'should access sources' do
    ActiveExport.config.sources.should == { :default => fixture_file('csv_1.yml') }
  end

  describe '[](key)' do
    subject { ActiveExport[:default] }
    it { should be_kind_of Hash }
    it { subject['author'].should == ['name', 'author.name', { 'price' => 'my_price_2' }] }
  end
end