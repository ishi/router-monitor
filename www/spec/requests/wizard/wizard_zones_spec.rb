require 'spec_helper'

describe "Wizard::Zones" do
  describe "GET /wizard_zones" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get wizard_zones_path
      response.status.should be(200)
    end
  end
end
