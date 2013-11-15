require 'spec_helper'

describe 'Create a Pattern' do

  it 'should make a basic Pattern' do
    pattern = create('pattern')
    pattern.value.should eq('1ZVBP8KS C')
  end
end