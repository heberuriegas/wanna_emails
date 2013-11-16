require 'spec_helper'

describe "Campaigns" do
  describe "GET /campaigns" do
    let(:project) { create :recollection }

    before(:each) do
      sign_in_user
    end
    
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get project_campaigns_path(project)
      response.status.should be(200)
    end
  end
end
