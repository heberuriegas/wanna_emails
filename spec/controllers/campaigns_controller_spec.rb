require 'spec_helper'

describe CampaignsController do

  let(:valid_attributes) { build(:campaign).attributes.merge(project_id: project.id) }
  let(:project) { create :project }

  before (:each) do
    sign_in_user
  end

  describe "GET index" do
    it "assigns all campaigns as @campaigns" do
      campaign = Campaign.create! valid_attributes
      get :index, {project_id: project.id}
      assigns(:campaigns).should eq([campaign])
    end
  end

  describe "GET show" do
    it "assigns the requested campaign as @campaign" do
      campaign = Campaign.create! valid_attributes
      get :show, {project_id: project.id, :id => campaign.to_param}
      assigns(:campaign).should eq(campaign)
    end
  end

  describe "GET new" do
    it "assigns a new campaign as @campaign" do
      get :new, {project_id: project.id}
      assigns(:campaign).should be_a_new(Campaign)
    end
  end

  describe "GET edit" do
    it "assigns the requested campaign as @campaign" do
      campaign = Campaign.create! valid_attributes
      get :edit, {project_id: project.id, :id => campaign.to_param}
      assigns(:campaign).should eq(campaign)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Campaign" do
        expect {
          post :create, {project_id: project.id, :campaign => valid_attributes}
        }.to change(Campaign, :count).by(1)
      end

      it "assigns a newly created campaign as @campaign" do
        post :create, {project_id: project.id, :campaign => valid_attributes}
        assigns(:campaign).should be_a(Campaign)
        assigns(:campaign).should be_persisted
      end

      it "redirects to the created campaign" do
        post :create, {project_id: project.id, :campaign => valid_attributes}
        response.should redirect_to(project_campaign_url(project,Campaign.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved campaign as @campaign" do
        # Trigger the behavior that occurs when invalid params are submitted
        Campaign.any_instance.stub(:save).and_return(false)
        post :create, {project_id: project.id, :campaign => { "name" => "invalid value" }}
        assigns(:campaign).should be_a_new(Campaign)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Campaign.any_instance.stub(:save).and_return(false)
        post :create, {project_id: project.id, :campaign => { "name" => "invalid value" }}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested campaign" do
        campaign = Campaign.create! valid_attributes
        # Assuming there are no other campaigns in the database, this
        # specifies that the Campaign created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Campaign.any_instance.should_receive(:update).with({ "name" => "MyString" })
        put :update, {project_id: project.id, :id => campaign.to_param, :campaign => { "name" => "MyString" }}
      end

      it "assigns the requested campaign as @campaign" do
        campaign = Campaign.create! valid_attributes
        put :update, {project_id: project.id, :id => campaign.to_param, :campaign => valid_attributes}
        assigns(:campaign).should eq(campaign)
      end

      it "redirects to the campaign" do
        campaign = Campaign.create! valid_attributes
        put :update, {project_id: project.id, :id => campaign.to_param, :campaign => valid_attributes}
        response.should redirect_to(project_campaign_url(project,campaign))
      end
    end

    describe "with invalid params" do
      it "assigns the campaign as @campaign" do
        campaign = Campaign.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Campaign.any_instance.stub(:save).and_return(false)
        put :update, {project_id: project.id,:id => campaign.to_param, :campaign => { "name" => "invalid value" }}
        assigns(:campaign).should eq(campaign)
      end

      it "re-renders the 'edit' template" do
        campaign = Campaign.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Campaign.any_instance.stub(:save).and_return(false)
        put :update, {project_id: project.id, :id => campaign.to_param, :campaign => { "name" => "invalid value" }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested campaign" do
      campaign = Campaign.create! valid_attributes
      expect {
        delete :destroy, {project_id: project.id, :id => campaign.to_param}
      }.to change(Campaign, :count).by(-1)
    end

    it "redirects to the campaigns list" do
      campaign = Campaign.create! valid_attributes
      delete :destroy, {project_id: project.id, :id => campaign.to_param}
      response.should redirect_to(project_campaigns_url(project))
    end
  end

end
