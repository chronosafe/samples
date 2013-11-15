require 'spec_helper'

describe "decodes/index" do
  before(:each) do
    assign(:decodes, [
      stub_model(Decode),
      stub_model(Decode)
    ])
  end

  it "renders a list of decodes" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
