# coding: utf-8

require 'spec_helper'

describe 'RailsSupport' do
  it { expect { Book.create!(name: 'test') }.to change(Book, :count).by(1) }
  it { expect { FactoryGirl.create(:book) }.to change(Book, :count).by(1) }
end