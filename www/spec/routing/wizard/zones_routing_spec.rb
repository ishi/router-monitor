require "spec_helper"

describe Wizard::ZonesController do
  describe "routing" do

    it "routes to #index" do
      get("/wizard_zones").should route_to("wizard_zones#index")
    end

    it "routes to #new" do
      get("/wizard_zones/new").should route_to("wizard_zones#new")
    end

    it "routes to #show" do
      get("/wizard_zones/1").should route_to("wizard_zones#show", :id => "1")
    end

    it "routes to #edit" do
      get("/wizard_zones/1/edit").should route_to("wizard_zones#edit", :id => "1")
    end

    it "routes to #create" do
      post("/wizard_zones").should route_to("wizard_zones#create")
    end

    it "routes to #update" do
      put("/wizard_zones/1").should route_to("wizard_zones#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/wizard_zones/1").should route_to("wizard_zones#destroy", :id => "1")
    end

  end
end
