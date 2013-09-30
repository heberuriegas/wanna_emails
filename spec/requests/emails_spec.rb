require 'spec_helper'

describe "Emails" do
  describe "GET /emails" do
    
    before(:each) do
      sign_in_user
    end

    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get emails_path
      response.status.should be(200)
    end
  end
end
