require "spec_helper"

describe MessagesController do
  describe "routing" do

    it "routes to #index" do
      get("/projects/2/messages").should route_to("messages#index", project_id: "2")
    end

    it "routes to #new" do
      get("/projects/2/messages/new").should route_to("messages#new", project_id: "2")
    end

    it "routes to #show" do
      get("/projects/2/messages/1").should route_to("messages#show", :id => "1", project_id: "2")
    end

    it "routes to #edit" do
      get("/projects/2/messages/1/edit").should route_to("messages#edit", :id => "1", project_id: "2")
    end

    it "routes to #create" do
      post("/projects/2/messages").should route_to("messages#create", project_id: "2")
    end

    it "routes to #update" do
      put("/projects/2/messages/1").should route_to("messages#update", :id => "1", project_id: "2")
    end

    it "routes to #destroy" do
      delete("/projects/2/messages/1").should route_to("messages#destroy", :id => "1", project_id: "2")
    end

  end
end
