require 'spec_helper'

describe ClassicVehicle do
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

  it 'should create a classic vehicle' do
    ClassicVehicle.count.should eq(1)
  end

  it 'should assign values to the vehicle' do
    @vehicle.year.should eq('1969')
    @vehicle.make.should eq('Ford')
    @vehicle.series.should eq('Mustang')
    @vehicle.name.should eq('Fastback')
  end

  it 'should have a pattern assigned' do
    @vehicle.classic_pattern.should eq(@pattern)
  end
end
