require 'spec_helper'

describe RecollectionsController do

  let(:valid_attributes) { build(:recollection).attributes.merge(project_id: project.id) }
  let(:project) { create :project }

  before(:each) do
    sign_in_user
  end

  describe "GET index" do
    it "assigns all recollections as @recollections" do
      recollection = Recollection.create! valid_attributes
      get :index, {project_id: project.id}
      assigns(:recollections).should eq([recollection])
    end
  end

  describe "GET show" do
    it "assigns the requested recollection as @recollection" do
      recollection = Recollection.create! valid_attributes
      get :show, {project_id: project.id, :id => recollection.to_param}
      assigns(:recollection).should eq(recollection)
    end
  end

  describe "GET new" do
    it "assigns a new recollection as @recollection" do
      get :new, {project_id: project.id}
      assigns(:recollection).should be_a_new(Recollection)
    end
  end

  describe "GET edit" do
    it "assigns the requested recollection as @recollection" do
      recollection = Recollection.create! valid_attributes
      get :edit, {project_id: project.id,:id => recollection.to_param}
      assigns(:recollection).should eq(recollection)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Recollection" do
        expect {
          post :create, {project_id: project.id, :recollection => valid_attributes}
        }.to change(Recollection, :count).by(1)
      end

      it "assigns a newly created recollection as @recollection" do
        post :create, {project_id: project.id, :recollection => valid_attributes}
        assigns(:recollection).should be_a(Recollection)
        assigns(:recollection).should be_persisted
      end

      it "redirects to the created recollection" do
        post :create, {project_id: project.id, :recollection => valid_attributes}
        response.should redirect_to(project_recollection_url(project, Recollection.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved recollection as @recollection" do
        # Trigger the behavior that occurs when invalid params are submitted
        Recollection.any_instance.stub(:save).and_return(false)
        post :create, {project_id: project.id,:recollection => { "name" => "invalid value" }}
        assigns(:recollection).should be_a_new(Recollection)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Recollection.any_instance.stub(:save).and_return(false)
        post :create, {project_id: project.id,:recollection => { "name" => "invalid value" }}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested recollection" do
        recollection = Recollection.create! valid_attributes
        # Assuming there are no other recollections in the database, this
        # specifies that the Recollection created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Recollection.any_instance.should_receive(:update).with({ "name" => "MyString" })
        put :update, {project_id: project.id,:id => recollection.to_param, :recollection => { "name" => "MyString" }}
      end

      it "assigns the requested recollection as @recollection" do
        recollection = Recollection.create! valid_attributes
        put :update, {project_id: project.id,:id => recollection.to_param, :recollection => valid_attributes}
        assigns(:recollection).should eq(recollection)
      end

      it "redirects to the recollection" do
        recollection = Recollection.create! valid_attributes
        put :update, {project_id: project.id,:id => recollection.to_param, :recollection => valid_attributes}
        response.should redirect_to(project_recollection_path(project, recollection))
      end
    end

    describe "with invalid params" do
      it "assigns the recollection as @recollection" do
        recollection = Recollection.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Recollection.any_instance.stub(:save).and_return(false)
        put :update, {project_id: project.id,:id => recollection.to_param, :recollection => { "name" => "invalid value" }}
        assigns(:recollection).should eq(recollection)
      end

      it "re-renders the 'edit' template" do
        recollection = Recollection.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Recollection.any_instance.stub(:save).and_return(false)
        put :update, {project_id: project.id,:id => recollection.to_param, :recollection => { "name" => "invalid value" }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested recollection" do
      recollection = Recollection.create! valid_attributes
      expect {
        delete :destroy, {project_id: project.id,:id => recollection.to_param}
      }.to change(Recollection, :count).by(-1)
    end

    it "redirects to the recollections list" do
      recollection = Recollection.create! valid_attributes
      delete :destroy, {project_id: project.id,:id => recollection.to_param}
      response.should redirect_to(project_recollections_url)
    end
  end

end
