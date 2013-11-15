require 'spec_helper'

describe AppLog do


  let(:user) { FactoryGirl.create(:admin) }
  let(:decode) { FactoryGirl.create(:decode) }
  let(:message) { 'Hello world' }

  before(:all) do
    AppLog.destroy_all
  end

  before(:each) do
    AppLog.destroy_all
  end

  it 'should create a record with just a message' do
    AppLog.create(message: message)
    AppLog.count.should eq(1)
    AppLog.first.message.should eq(message)
  end

  it 'should create a record with a user' do
    AppLog.log_with_user(user, message)
    AppLog.count.should eq(1)
    AppLog.first.message.should eq(message)
    AppLog.first.user.should eq(user)
  end

  it 'should create a record with a decode' do
    AppLog.log_with_decode(decode, message)
    AppLog.count.should eq(1)
    AppLog.first.message.should eq(message)
    AppLog.first.decode.should eq(decode)
  end

end
