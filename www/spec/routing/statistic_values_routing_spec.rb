require "spec_helper"

describe StatisticValuesController do
  describe "routing" do

    it "routes to #index" do
      get("/statistic_values").should route_to("statistic_values#index")
    end

    it "routes to #new" do
      get("/statistic_values/new").should route_to("statistic_values#new")
    end

    it "routes to #show" do
      get("/statistic_values/1").should route_to("statistic_values#show", :id => "1")
    end

    it "routes to #edit" do
      get("/statistic_values/1/edit").should route_to("statistic_values#edit", :id => "1")
    end

    it "routes to #create" do
      post("/statistic_values").should route_to("statistic_values#create")
    end

    it "routes to #update" do
      put("/statistic_values/1").should route_to("statistic_values#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/statistic_values/1").should route_to("statistic_values#destroy", :id => "1")
    end

  end
end
