require 'spec_helper'

describe InvoiceSubscription do
  before(:all) do
    InvoiceSubscription.destroy_all
  end

  it 'should create a subscription object' do
    @sub = InvoiceSubscription.new
    @sub.save
    InvoiceSubscription.count.should eq(1)
  end
end