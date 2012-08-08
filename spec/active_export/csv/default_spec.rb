# coding: utf-8

require 'spec_helper'

describe ActiveExport::Csv::Default do
  describe ".export" do
    it do
      expect { Book.create!(name: 'test') }.to change(Book, :count).by(1)
      ActiveExport::Csv::Default.export([])
    end
  end
end