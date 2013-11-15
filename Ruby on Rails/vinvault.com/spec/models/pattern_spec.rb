require 'spec_helper'

# NOTE: Don't make assumptions on order of vehicles from decode!

describe 'Create pattern based on XML' do
  before(:all) do
    Pattern.destroy_all
    @stub = create('pattern')
    @valid = create('valid')

    load "#{Rails.root}/db/seeds.rb"
    path = File.dirname(__FILE__) + '/../vehicle1.xml'
    xml = File.read(path)
    xml.should_not be_nil
    @pattern = Pattern.read_xml(xml)
    @coupe = @pattern.vehicles.where('trim = ?', 'Sport Coupe').first
    @coupes = @pattern.vehicles.where('trim = ?', 'Sport Coupe S').first
  end

  it 'should record the VIN of the vehicle for future use' do
    @pattern.vin.should eq('JTKDE167280264158')
  end

  it 'should have the right pattern' do
    @pattern.value.should eq('JTKDE167 8')
  end

  it 'should have 2008 as the Year' do
    @pattern.year.should eq('2008')
  end

  it 'should have Scion as the Make' do
    @pattern.make.should eq('Scion')
  end

  it 'should have Scion as the Series' do
    @pattern.series.should eq('tC')
  end

  it 'should have 2 vehicles' do
    @pattern.vehicles.count.should eq(2)
  end

  it 'should have the first vehicle have 155 items' do
    @coupe.items.count.should eq(155)
  end

  it 'should have the value of Model Year for the first item' do
    i = @coupe.items.first
    i.should_not be_nil
    i.value.should eq('2008')
    i.category.should eq(Category.named('Model Year'))
  end

  it 'should have a vehicle with a Sport Coupe trim level' do
    @coupe.should_not be_nil
  end

  it 'should have a vehicle with a Sport Coupe S trim level' do
    @coupes.should_not be_nil
  end

  it 'should have color values for the first item' do
    i = @coupe.items.where(category: Category.named('Exterior Color')).first
    i.should_not be_nil
    i.value.should eq(nil)
    i.category.should eq(Category.named('Exterior Color'))
  end

  it 'should have 7 options for colors when separated by |' do
    i = @coupe.items.where(category: Category.named('Exterior Color')).first
    i.should_not be_nil
    i.item_options.count.should eq(7)
  end

  it 'should have 7 options for colors when separated by ,' do
    i = @coupes.items.where(category: Category.named('Exterior Color')).first
    i.should_not be_nil
    i.item_options.count.should eq(7)
  end

  it 'should have 2 options for transmissions' do
    i = @coupes.items.where(category: Category.named('Transmission-short')).first
    i.should_not be_nil
    i.item_options.count.should eq(2)
  end

  it 'should have 2 options for transmissions long name' do
    i = @coupes.items.where(category: Category.named('Transmission-long')).first
    i.should_not be_nil
    i.item_options.count.should eq(2)
  end

  it 'should have an MSRP as a value ($17,000)' do
    i = @coupes.items.where(category: Category.named('MSRP')).first
    i.should_not be_nil
    i.item_options.count.should eq(0)
    i.value.should eq('$17,000')
  end

  it 'should have a warranty mileage as a value (36,000)' do
    i = @coupes.items.where(category: Category.named('Basic-distance')).first
    i.should_not be_nil
    i.item_options.count.should eq(0)
    i.value.should eq('36,000')
  end

  it 'should know when it needs to be refreshed' do
    @pattern.needs_refresh?.should be_true
    @stub.needs_refresh?.should be_true
  end

  it 'should set update_needed on create' do
    @pattern.needs_update?.should be_false # Real record
    @stub.needs_update?.should be_true # No vehicles
    @valid.needs_update?.should be_true # Set true in factory
  end

end