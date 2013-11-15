require 'spec_helper'

describe ClassicItemOption do
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

  it 'should create an classic item_option' do
    ClassicItemOption.count.should eq(1)
  end

  it 'should have a classic item' do
    @option.classic_item.should eq(@item)
  end
end
