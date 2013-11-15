FactoryGirl.define do
  load "#{Rails.root}/app/models/user.rb"
  factory User do |user|
    email 'basic@example.com'
    password '12345678'
    password_confirmation '12345678'
  end

  factory :admin, class: User do |user|
    email 'admin1@example.com'
    password '12345678'
    password_confirmation '12345678'
    user.subscription FreeSubscription.create(active: true)
    after(:create) do |u|
      u.add_role(:admin)
    end
  end

  factory :platinum, class: User do |user|
    email 'plat1@example.com'
    password '12345678'
    password_confirmation '12345678'
    user.subscription StripeSubscription.create(active: true)
    authentication_token 'platinum'
    after(:create) do |u|
      u.add_role(:platinum)
    end
  end

  factory :bronze, class: User do |user|
    email 'bronze1@example.com'
    password '12345678'
    password_confirmation '12345678'
    user.subscription FreeSubscription.create(active: true)
    after(:create) do |u|
      u.add_role(:bronze)
    end
  end

  factory :basic, class: User do |user|
    email 'basic1@example.com'
    password '12345678'
    password_confirmation '12345678'
    user.subscription FreeSubscription.create(active: true)
  end

  factory :guest, class: User do |user|
    email 'bguest@example.com'
    password '12345678'
    password_confirmation '12345678'
    user.subscription FreeSubscription.create(active: true)
  end

  factory :no_role, class: User do |user|
    email 'bguest@example.com'
    password '12345678'
    password_confirmation '12345678'
    user.subscription FreeSubscription.create(active: true)
  end
end