require 'spec_helper'

describe ClassicPattern do
  before(:all) do
    ClassicCategory.destroy_all
    ClassicGroup.destroy_all
    ClassicItem.destroy_all
    ClassicItemOption.destroy_all
    ClassicVehicle.destroy_all
    ClassicSerial.destroy_all
    ClassicPattern.destroy_all
    @item = FactoryGirl.create(:classic_item)
    @option = FactoryGirl.create(:classic_item_option)
    @pattern = FactoryGirl.create(:classic_pattern)
    @serial = FactoryGirl.create(:classic_serial)
    @vehicle = FactoryGirl.create(:classic_vehicle)
    @category = FactoryGirl.create(:classic_category)
    @group = FactoryGirl.create(:classic_group)
  end

  it 'should create a classic pattern' do
    ClassicPattern.count.should eq(1)
  end

  it 'should have a serial assigned' do
    @pattern.classic_serials.count.should eq(1)
  end

  it 'should see serial 1000 as in range' do
    @pattern.in_range('9T02M900001').should be_true
  end

  it 'should see serial 20000 as out of range' do
    @pattern.in_range('9T02M000001').should be_false
  end

  it 'should see any value as being in range if there are no ranges assigned' do
    @serial.delete
    @pattern.in_range('9T02M000001').should be_true
  end
end
