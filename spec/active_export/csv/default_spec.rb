# coding: utf-8

require 'spec_helper'

describe ActiveExport::Csv::Default do
  describe ".export" do
    it do
      ActiveExport::Csv::Default.export([])
    end
  end
end