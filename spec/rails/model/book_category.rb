# coding: utf-8

class BookCategory < ActiveRecord::Base
  belongs_to :book
  belongs_to :category
end