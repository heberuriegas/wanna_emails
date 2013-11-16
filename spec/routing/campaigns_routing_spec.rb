require "spec_helper"

describe CampaignsController do
  describe "routing" do

    it "routes to #index" do
      get("/projects/2/campaigns").should route_to("campaigns#index", project_id: "2")
    end

    it "routes to #new" do
      get("/projects/2/campaigns/new").should route_to("campaigns#new", project_id: "2")
    end

    it "routes to #show" do
      get("/projects/2/campaigns/1").should route_to("campaigns#show", :id => "1", project_id: "2")
    end

    it "routes to #edit" do
      get("/projects/2/campaigns/1/edit").should route_to("campaigns#edit", :id => "1", project_id: "2")
    end

    it "routes to #create" do
      post("/projects/2/campaigns").should route_to("campaigns#create", project_id: "2")
    end

    it "routes to #update" do
      put("/projects/2/campaigns/1").should route_to("campaigns#update", :id => "1", project_id: "2")
    end

    it "routes to #destroy" do
      delete("/projects/2/campaigns/1").should route_to("campaigns#destroy", :id => "1", project_id: "2")
    end

  end
end
