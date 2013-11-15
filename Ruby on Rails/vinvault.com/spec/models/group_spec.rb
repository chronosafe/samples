require 'spec_helper'

describe Group do

  before(:all) do

    load "#{Rails.root}/db/seeds.rb"
  end

  it 'should find 18 Group types' do
    Group.count.should eq(18)
  end

  it 'should find Basic group' do
    Group.named('Basic').should_not be_nil
    Group.named('Basic').code.should eq('BASIC')
  end
end