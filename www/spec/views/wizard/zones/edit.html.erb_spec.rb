require 'spec_helper'

describe "wizard_zones/edit" do
  before(:each) do
    @zone = assign(:zone, stub_model(Wizard::Zone))
  end

  it "renders the edit zone form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => wizard_zones_path(@zone), :method => "post" do
    end
  end
end
