require "spec_helper"

describe SendersController do
  describe "routing" do

    it "routes to #index" do
      get("/senders").should route_to("senders#index")
    end

    it "routes to #new" do
      get("/senders/new").should route_to("senders#new")
    end

    it "routes to #show" do
      get("/senders/1").should route_to("senders#show", :id => "1")
    end

    it "routes to #edit" do
      get("/senders/1/edit").should route_to("senders#edit", :id => "1")
    end

    it "routes to #create" do
      post("/senders").should route_to("senders#create")
    end

    it "routes to #update" do
      put("/senders/1").should route_to("senders#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/senders/1").should route_to("senders#destroy", :id => "1")
    end

  end
end
