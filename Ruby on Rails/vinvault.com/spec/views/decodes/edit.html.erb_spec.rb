require 'spec_helper'

describe "decodes/edit" do
  before(:each) do
    @decode = assign(:decode, stub_model(Decode))
  end

  it "renders the edit decode form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", decode_path(@decode), "post" do
    end
  end
end
