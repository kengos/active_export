FactoryGirl.define do
  factory :book do
    sequence(:name) {|n| "book_#{n}" }
  end
end