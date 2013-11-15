require 'spec_helper'


describe User do
  before (:each) do
    User.delete_all
  end

  it 'should create a valid user' do
    @user = FactoryGirl.create(:basic)
    @user.email.should eq('basic1@example.com')
  end
end
