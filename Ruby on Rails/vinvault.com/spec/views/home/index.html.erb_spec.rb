require 'spec_helper'

describe 'home/index' do

  it 'should contain Supercharge' do
    render
    expect(rendered).to include('Supercharge')
  end
end
