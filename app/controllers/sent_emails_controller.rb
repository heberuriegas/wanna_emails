class SentEmailsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_api!
  respond_to :json

  def create
    render json: GeneralMailer.basic(params).deliver!
  end
end