require 'spec_helper'

describe 'registrations/new' do
  before(:all) do
    load "#{Rails.root}/db/seeds.rb"
  end

  it 'should tell user to select a plan if none present' do
    visit new_user_registration_path
    expect(page).to have_content 'Please select a subscription plan first.'
  end

  it 'should mention bronze plan if it is selected' do
    visit new_user_registration_path(plan: 'bronze')
    expect(page).to have_content 'Bronze'
  end
  it 'should mention silver plan if it is selected' do
    visit new_user_registration_path(plan: 'silver')
    expect(page).to have_content 'Silver'
  end
  it 'should mention gold plan if it is selected' do
    visit new_user_registration_path(plan: 'gold')
    expect(page).to have_content 'Gold'
  end
  it 'should mention platinum plan if it is selected' do
    visit new_user_registration_path(plan: 'platinum')
    expect(page).to have_content 'Platinum'
  end
end