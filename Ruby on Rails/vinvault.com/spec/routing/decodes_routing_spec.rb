require "spec_helper"

describe DecodesController do
  describe "routing" do

    it "routes to #index" do
      get("/decodes").should route_to("decodes#index")
    end

    it "routes to #new" do
      get("/decodes/new").should route_to("decodes#new")
    end

    it "routes to #show" do
      get("/decodes/1").should route_to("decodes#show", :id => "1")
    end

    it "routes to #edit" do
      get("/decodes/1/edit").should route_to("decodes#edit", :id => "1")
    end

    it "routes to #create" do
      post("/decodes").should route_to("decodes#create")
    end

    it "routes to #update" do
      put("/decodes/1").should route_to("decodes#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/decodes/1").should route_to("decodes#destroy", :id => "1")
    end

  end
end
