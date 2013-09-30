require 'spec_helper'

describe PagesController do

  let(:valid_attributes) { build(:page).attributes }
  let(:project) { create :project }

  before(:each) do
    pending
    sign_in_user
  end

  describe "GET index" do
    it "assigns all pages as @pages" do
      page = Page.create! valid_attributes
      get :index, {project_id: project.id}
      assigns(:pages).should eq([page])
    end
  end

  describe "GET show" do
    it "assigns the requested page as @page" do
      page = Page.create! valid_attributes
      get :show, {project_id: project.id, :id => page.to_param}
      assigns(:page).should eq(page)
    end
  end

  describe "GET new" do
    it "assigns a new page as @page" do
      get :new, {project_id: project.id}
      assigns(:page).should be_a_new(Page)
    end
  end

  describe "GET edit" do
    it "assigns the requested page as @page" do
      page = Page.create! valid_attributes
      get :edit, {project_id: project.id, :id => page.to_param}
      assigns(:page).should eq(page)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Page" do
        expect {
          post :create, {project_id: project.id, :page => valid_attributes}
        }.to change(Page, :count).by(1)
      end

      it "assigns a newly created page as @page" do
        post :create, {project_id: project.id, :page => valid_attributes}
        assigns(:page).should be_a(Page)
        assigns(:page).should be_persisted
      end

      it "redirects to the created page" do
        post :create, {project_id: project.id, :page => valid_attributes}
        response.should redirect_to(Page.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved page as @page" do
        # Trigger the behavior that occurs when invalid params are submitted
        Page.any_instance.stub(:save).and_return(false)
        post :create, {project_id: project.id, :page => { "host" => "invalid value" }}
        assigns(:page).should be_a_new(Page)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Page.any_instance.stub(:save).and_return(false)
        post :create, {project_id: project.id, :page => { "host" => "invalid value" }}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested page" do
        page = Page.create! valid_attributes
        # Assuming there are no other pages in the database, this
        # specifies that the Page created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Page.any_instance.should_receive(:update).with({ "host" => "MyString" })
        put :update, {project_id: project.id, :id => page.to_param, :page => { "host" => "MyString" }}
      end

      it "assigns the requested page as @page" do
        page = Page.create! valid_attributes
        put :update, {project_id: project.id, :id => page.to_param, :page => valid_attributes}
        assigns(:page).should eq(page)
      end

      it "redirects to the page" do
        page = Page.create! valid_attributes
        put :update, {project_id: project.id, :id => page.to_param, :page => valid_attributes}
        response.should redirect_to(page)
      end
    end

    describe "with invalid params" do
      it "assigns the page as @page" do
        page = Page.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Page.any_instance.stub(:save).and_return(false)
        put :update, {project_id: project.id, :id => page.to_param, :page => { "host" => "invalid value" }}
        assigns(:page).should eq(page)
      end

      it "re-renders the 'edit' template" do
        page = Page.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Page.any_instance.stub(:save).and_return(false)
        put :update, {project_id: project.id, :id => page.to_param, :page => { "host" => "invalid value" }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested page" do
      page = Page.create! valid_attributes
      expect {
        delete :destroy, {project_id: project.id, :id => page.to_param}
      }.to change(Page, :count).by(-1)
    end

    it "redirects to the pages list" do
      page = Page.create! valid_attributes
      delete :destroy, {project_id: project.id, :id => page.to_param}
      response.should redirect_to(pages_url)
    end
  end

end
