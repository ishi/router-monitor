require 'spec_helper'

describe "wizard_zones/show" do
  before(:each) do
    @zone = assign(:zone, stub_model(Wizard::Zone))
  end

  it "renders attributes in <p>" do
    render
  end
end
