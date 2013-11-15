require 'spec_helper'

describe ClassicGroup do
  before(:all) do
    ClassicCategory.destroy_all
    ClassicGroup.destroy_all
    @category = FactoryGirl.create(:classic_category)
    @group = FactoryGirl.create(:classic_group)
  end

  it 'should create a group' do
    ClassicGroup.count.should eq(1)
    @group.name.should eq('Engine')
  end

  it 'should have many categories' do
    @group.classic_categories.count.should eq(1)
  end
end
