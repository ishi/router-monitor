require 'spec_helper'

describe "wizard_zones/index" do
  before(:each) do
    assign(:wizard_zones, [
      stub_model(Wizard::Zone),
      stub_model(Wizard::Zone)
    ])
  end

  it "renders a list of wizard_zones" do
    render
  end
end
