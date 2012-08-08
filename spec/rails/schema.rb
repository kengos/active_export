ActiveRecord::Schema.define(version: 1) do
  create_table :books, force: true do |t|
    t.string   :name
    t.integer  :author_id
    t.integer  :price
  end

  create_table :authors, force: true do |t|
    t.string :name
  end

  create_table :categories, force: true do |t|
    t.string :name
  end

  create_table :book_categories, force: true do |t|
    t.integer :book_id
    t.integer :category_id
  end
end