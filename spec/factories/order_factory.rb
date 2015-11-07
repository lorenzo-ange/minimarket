FactoryGirl.define do
  factory :order do
    name { Faker::Name.name }
    address { "#{Faker::Address.street_address} #{Faker::Address.city} (#{Faker::Address.zip_code})" }
    email { Faker::Internet.email }
    pay_type { Order::PAYMENT_TYPES.sample }
  end
end
