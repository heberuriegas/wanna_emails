require 'spec_helper'

describe MessagesController do

  let(:valid_attributes) { build(:message).attributes.merge(project_id: project.id) }
  let(:project) { create :project }

  before(:each) do
    sign_in_user
  end

  describe "GET index" do
    it "assigns all messages as @messages" do
      message = Message.create! valid_attributes
      get :index, {:project_id => project.id}
      assigns(:messages).should eq([message])
    end
  end

  describe "GET show" do
    it "assigns the requested message as @message" do
      message = Message.create! valid_attributes
      get :show, {:project_id => project.id, :id => message.to_param}
      assigns(:message).should eq(message)
    end
  end

  describe "GET new" do
    it "assigns a new message as @message" do
      get :new, {:project_id => project.id}
      assigns(:message).should be_a_new(Message)
    end
  end

  describe "GET edit" do
    it "assigns the requested message as @message" do
      message = Message.create! valid_attributes
      get :edit, {:project_id => project.id, :id => message.to_param}
      assigns(:message).should eq(message)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Message" do
        expect {
          post :create, {:project_id => project.id, :message => valid_attributes}
        }.to change(Message, :count).by(1)
      end

      it "assigns a newly created message as @message" do
        post :create, {:project_id => project.id, :message => valid_attributes}
        assigns(:message).should be_a(Message)
        assigns(:message).should be_persisted
      end

      it "redirects to the created message" do
        post :create, {:project_id => project.id, :message => valid_attributes}
        response.should redirect_to(project_message_path(project,Message.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved message as @message" do
        # Trigger the behavior that occurs when invalid params are submitted
        Message.any_instance.stub(:save).and_return(false)
        post :create, {:project_id => project.id, :message => { "subject" => "invalid value" }}
        assigns(:message).should be_a_new(Message)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Message.any_instance.stub(:save).and_return(false)
        post :create, {:project_id => project.id, :message => { "subject" => "invalid value" }}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested message" do
        message = Message.create! valid_attributes
        # Assuming there are no other messages in the database, this
        # specifies that the Message created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Message.any_instance.should_receive(:update).with({ "subject" => "MyString" })
        put :update, {:project_id => project.id, :id => message.to_param, :message => { "subject" => "MyString" }}
      end

      it "assigns the requested message as @message" do
        message = Message.create! valid_attributes
        put :update, {:project_id => project.id, :id => message.to_param, :message => valid_attributes}
        assigns(:message).should eq(message)
      end

      it "redirects to the message" do
        message = Message.create! valid_attributes
        put :update, {:project_id => project.id, :id => message.to_param, :message => valid_attributes}
        response.should redirect_to(project_message_path(project, message))
      end
    end

    describe "with invalid params" do
      it "assigns the message as @message" do
        message = Message.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Message.any_instance.stub(:save).and_return(false)
        put :update, {:project_id => project.id, :id => message.to_param, :message => { "subject" => "invalid value" }}
        assigns(:message).should eq(message)
      end

      it "re-renders the 'edit' template" do
        message = Message.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Message.any_instance.stub(:save).and_return(false)
        put :update, {:project_id => project.id, :id => message.to_param, :message => { "subject" => "invalid value" }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested message" do
      message = Message.create! valid_attributes
      expect {
        delete :destroy, {:project_id => project.id, :id => message.to_param}
      }.to change(Message, :count).by(-1)
    end

    it "redirects to the messages list" do
      message = Message.create! valid_attributes
      delete :destroy, {:project_id => project.id, :id => message.to_param}
      response.should redirect_to(project_messages_url(project))
    end
  end

end
