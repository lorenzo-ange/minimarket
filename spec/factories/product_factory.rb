FactoryGirl.define do
  factory :product do
    sequence(:title) { |n| "#{Faker::Book.title}#{n}" }
    description { Faker::Lorem.paragraph }
    image_url { Faker::Company.logo }
    price { Faker::Commerce.price }
  end
end
