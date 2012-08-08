# coding: utf-8

class Author < ActiveRecord::Base
  has_many :books
end