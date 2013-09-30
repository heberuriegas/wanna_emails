require "spec_helper"

describe RecollectionsController do
  describe "routing" do

    it "routes to #index" do
      get("/projects/2/recollections").should route_to("recollections#index", project_id: "2")
    end

    it "routes to #new" do
      get("/projects/2/recollections/new").should route_to("recollections#new", project_id: "2")
    end

    it "routes to #show" do
      get("/projects/2/recollections/1").should route_to("recollections#show", :id => "1", project_id: "2")
    end

    it "routes to #edit" do
      get("/projects/2/recollections/1/edit").should route_to("recollections#edit", :id => "1", project_id: "2")
    end

    it "routes to #create" do
      post("/projects/2/recollections").should route_to("recollections#create", project_id: "2")
    end

    it "routes to #update" do
      put("/projects/2/recollections/1").should route_to("recollections#update", :id => "1", project_id: "2")
    end

    it "routes to #destroy" do
      delete("/projects/2/recollections/1").should route_to("recollections#destroy", :id => "1", project_id: "2")
    end

  end
end
