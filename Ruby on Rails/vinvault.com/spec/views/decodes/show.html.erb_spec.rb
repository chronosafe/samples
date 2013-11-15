require 'spec_helper'

describe "decodes/show" do
  before(:each) do
    @decode = assign(:decode, stub_model(Decode))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
