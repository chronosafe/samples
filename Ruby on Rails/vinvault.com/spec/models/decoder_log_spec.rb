require 'spec_helper'

describe DecoderLog do
  before(:all) do
    load "#{Rails.root}/db/seeds.rb"
    FactoryGirl.create(:pattern)
    @valid_vin = { vin: '1ZVBP8KS0C5250988' }
    @decode = Decode.new(@valid_vin)
    @decode.user = User.first
    @decode.save
    DecoderLog.delete_all
    @decoder_log = DecoderLog.create(decode: @decode, ip_address: '127.0.0.1', user_id: @decode.user.id)
  end
  it 'should have a decode assigned' do

    DecoderLog.count.should eq(1)
    DecoderLog.first.decode.should eq(@decode)
  end

  it 'should have a user assigned' do
    @decoder_log.user.should eq(@decode.user)
  end

  it 'should report one decode for the day, month, and year for decode' do
    DecoderLog.count.should eq(1)
    DecoderLog.this_week.where(decode: @decode).count.should eq(1)
    DecoderLog.this_month.where(decode: @decode).count.should eq(1)
    DecoderLog.this_year.where(decode: @decode).count.should eq(1)
  end

  it 'should have 1 decode for the current user in all statistics' do
    DecoderLog.count.should eq(1)
    DecoderLog.this_week.where(user: @decode.user).count.should eq(1)
    DecoderLog.this_month.where(user: @decode.user).count.should eq(1)
    DecoderLog.this_year.where(user: @decode.user).count.should eq(1)
  end
end
