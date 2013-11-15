require 'spec_helper'

describe 'home/plans' do

  it 'should contain 4 Plans' do
    render
    expect(rendered).to include('Bronze')
    expect(rendered).to include('Silver')
    expect(rendered).to include('Gold')
    expect(rendered).to include('Platinum')
  end
end