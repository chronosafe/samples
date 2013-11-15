require 'spec_helper'

describe FreeSubscription do
  before(:all) do
    FreeSubscription.destroy_all
  end

  it 'should create a subscription object' do
    @sub = FreeSubscription.new
    @sub.save
    FreeSubscription.count.should eq(1)
  end
end