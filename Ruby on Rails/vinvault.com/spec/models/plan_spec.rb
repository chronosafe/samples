require 'spec_helper'

describe Plan do

  before(:all) do
    load "#{Rails.root}/db/seeds.rb"
  end

  it 'should return a role assigned to it' do
    Plan.first.role.should be_a(Role)
  end
end
