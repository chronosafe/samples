FactoryGirl.define do
  factory :decode do
    vin '1D7RB1CT8AS203937'
  end

  factory :invalid_checkdigit, class: Decode do
    vin '1D7RB1CT8AS203930'
  end
end