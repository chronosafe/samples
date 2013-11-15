require 'spec_helper'

describe ClassicCategory do
  before(:all) do
    ClassicCategory.destroy_all
    ClassicGroup.destroy_all
    @category = FactoryGirl.create(:classic_category)
    @group = FactoryGirl.create(:classic_group)
  end

  it 'creates a classic category' do
    ClassicCategory.count.should eq(1)
    @category.name.should eq('Transmission Type')
  end

  it 'should have a group assigned' do
    @category.classic_group.should eq(@group)
  end
end
