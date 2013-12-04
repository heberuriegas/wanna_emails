class SentEmailsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_api!
  respond_to :json

  def create
    GeneralMailer.basic(params).deliver!
    render json: 'ok'
  end
end