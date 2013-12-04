class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def authenticate_api!
    raise("Authentication error.") if ENV['API_TOKEN'].present? && ENV['API_TOKEN'] != params[:api_token]
  end

  rescue_from CanCan::AccessDenied do |e|
    respond_to do |format|      
      format.html { redirect_to root_path, :alert => e.message }
      format.json { render json: e.message, status: :unauthorized }
    end
  end

  rescue_from StandardError do |e|
    respond_to do |format|      
      format.html { redirect_to root_path, :alert => e.message }
      format.json { render json: e.message, status: :unprocessable_entity }
    end
  end

end
