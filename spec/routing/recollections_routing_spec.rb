require "spec_helper"

describe RecollectionsController do
  describe "routing" do

    it "routes to #index" do
      get("/recollections").should route_to("recollections#index")
    end

    it "routes to #new" do
      get("/recollections/new").should route_to("recollections#new")
    end

    it "routes to #show" do
      get("/recollections/1").should route_to("recollections#show", :id => "1")
    end

    it "routes to #edit" do
      get("/recollections/1/edit").should route_to("recollections#edit", :id => "1")
    end

    it "routes to #create" do
      post("/recollections").should route_to("recollections#create")
    end

    it "routes to #update" do
      put("/recollections/1").should route_to("recollections#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/recollections/1").should route_to("recollections#destroy", :id => "1")
    end

  end
end
