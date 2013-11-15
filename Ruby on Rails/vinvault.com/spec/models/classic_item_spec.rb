require 'spec_helper'

describe ClassicItem do
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

  it 'should create an classic item' do
    ClassicItem.count.should eq(1)
  end

  it 'should have a classic category assigned' do
    @item.classic_category.should eq(@category)
  end

  it 'should have a vehicle assigned' do
    @item.classic_vehicle.should eq(@vehicle)
  end
end
