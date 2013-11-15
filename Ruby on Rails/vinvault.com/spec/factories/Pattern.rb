FactoryGirl.define do
  factory :pattern do
    value  '1ZVBP8KS C'
    year   '2012'
    make   'Ford'
    series 'Shelby GT500'
    update_needed false
  end

  factory :valid, class: Pattern do
    value  '1D7RB1CT A'
    year   '2012'
    make   'Ford'
    series 'Shelby GT500'
    update_needed true
  end
end