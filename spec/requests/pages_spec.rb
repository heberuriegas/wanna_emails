require 'spec_helper'

describe "Pages" do
  describe "GET /pages" do
    let(:project) { create(:project) }

    it "works! (now write some real specs)" do
      pending
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get project_pages_path(project.id)
      response.status.should be(200)
    end
  end
end
