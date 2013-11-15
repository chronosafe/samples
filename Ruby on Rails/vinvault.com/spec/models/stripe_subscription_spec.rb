require 'spec_helper'

describe StripeSubscription do
 before(:all) do
   StripeSubscription.destroy_all
 end

 it 'should create a subscription object' do
   @sub = StripeSubscription.new
   @sub.save
   StripeSubscription.count.should eq(1)
 end
end
