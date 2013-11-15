require 'spec_helper'

describe "decodes/new" do
  before(:each) do
    assign(:decode, stub_model(Decode).as_new_record)
  end

  it "renders new decode form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", decodes_path, "post" do
    end
  end
end
