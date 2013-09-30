class RecollectionPagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project

  def index
    @recollection_pages = RecollectionPage.joins(:recollection).includes(:page).where('recollections.project_id' => @project.id).order(emails_recollection_pages_count: :desc).page(params[:page])
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
end
