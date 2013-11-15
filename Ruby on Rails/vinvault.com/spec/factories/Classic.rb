FactoryGirl.define do

  factory :classic_pattern do
    value   '9T02M\d{6}'
    id      200
  end

  factory :classic_vehicle do
    year    '1969'
    make    'Ford'
    series  'Mustang'
    name    'Fastback'
    id      1000
    classic_pattern_id 200
  end

  factory :classic_item do
    value 'Transmission'
    id    1
    classic_category_id 1
    classic_vehicle_id  1000
  end

  factory :classic_item_option do
    value 'Red'
    classic_item_id 1
  end

  factory :classic_category do
    name 'Transmission Type'
    id    1
    classic_group_id 1
  end

  factory :classic_group do
    name 'Engine'
    id    1
  end

  factory :classic_serial do
    digits 6
    start_value 499999
    end_value   999999
    classic_pattern_id 200
  end

end