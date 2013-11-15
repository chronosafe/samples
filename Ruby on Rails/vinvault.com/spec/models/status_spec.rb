require 'spec_helper'



describe Status do

  before(:all) do
    load "#{Rails.root}/db/seeds.rb"
  end

  it 'should find 11 status types' do
    Status.count.should eq(12)
  end

  it 'should find SUCCESS status' do
    Status.named('VALID').should_not be_nil
  end
end
