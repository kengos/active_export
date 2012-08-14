# coding: utf-8

require 'spec_helper'

describe ActiveExport do
  it 'should access sources' do
    ActiveExport.configure do |config|
      config.sources = { :default => fixture_file('csv_1.yml') }
    end
    ActiveExport.config.sources.should == { :default => fixture_file('csv_1.yml') }
  end

  describe '[](key)' do
    context "configuration always_reload is false" do
      before {
        ActiveExport.configure do |config|
          config.sources = { default: fixture_file('csv_1.yml') }
          config.always_reload = false
        end
        ActiveExport[:default]
        ActiveExport.should_not_receive(:load!).with(:default)
      }
      subject { ActiveExport[:default] }
      it { should be_kind_of Hash }
      it { subject['book_1'].should be_present }
      it { subject[:book_2].should be_present }
    end

    context "configuration always_reload is true" do
      before {
        ActiveExport.configure do |config|
          config.sources = { default: fixture_file('csv_1.yml') }
          config.always_reload = true
        end
      }
      it 'should call load!' do
        ActiveExport[:default]
        ActiveExport.should_receive(:load!).with(:default)
        ActiveExport[:default]
      end
    end
  end
end