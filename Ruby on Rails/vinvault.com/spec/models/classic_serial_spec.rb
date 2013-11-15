require 'spec_helper'

describe ClassicSerial do
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

  it 'should create a serial record' do
    ClassicSerial.count.should eq(1)
  end

  it 'should have values assigned' do
    @serial.digits.should eq(6)
    @serial.start_value.should eq(499999)
    @serial.end_value.should eq(999999)
  end

  it 'should be assigned to a pattern' do
    @serial.classic_pattern.should eq(@pattern)
  end
end
