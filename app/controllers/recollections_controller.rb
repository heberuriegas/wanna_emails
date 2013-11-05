class RecollectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_default_create_params, only: [:create]
  before_action :set_recollection, only: [:show, :edit, :update, :destroy]

  # GET /recollections
  # GET /recollections.json
  def index
    @recollections = Recollection.where(project_id: params[:project_id]).order(date: :desc).page(params[:page])
    @hash = Gmaps4rails.build_markers(@recollections) do |recollection, marker|
      marker.lat recollection.latitude
      marker.lng recollection.longitude
    end
  end

  # GET /recollections/1
  # GET /recollections/1.json
  def show
    @recollection.start if params[:start].present? && @recollection.state_name == :waiting
    @recollection.try_again if params[:try_again].present? && (@recollection.state_name == :failed || params[:force] == 'true')
  end

  # GET /recollections/new
  def new
    @recollection = Recollection.new
  end

  # GET /recollections/1/edit
  def edit
  end

  # POST /recollections
  # POST /recollections.json
  def create
    @recollection = Recollection.new(recollection_params)
    respond_to do |format|
      if @recollection.save
        format.html { redirect_to project_recollection_path(@project,@recollection), notice: 'Recollection was successfully created.' }
        format.json { render action: 'show', status: :created, location: project_recollection_path(@project,@recollection) }
      else
        format.html { render action: 'new' }
        format.json { render json: @recollection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /recollections/1
  # PATCH/PUT /recollections/1.json
  def update
    respond_to do |format|
      if @recollection.update(recollection_params)
        format.html { redirect_to project_recollection_path(@project,@recollection), notice: 'Recollection was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @recollection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recollections/1
  # DELETE /recollections/1.json
  def destroy
    @recollection.destroy
    respond_to do |format|
      format.html { redirect_to project_recollections_url(@project.id) }
      format.json { head :no_content }
    end
  end

  private
    def set_project
      @project = Project.find(params[:project_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_recollection
      @recollection = Recollection.find(params[:id])
    end

    def default_params
      @default_params ||= {}
      @default_params.merge!(project_id: @project.id) unless @recollection.present? and @recollection.project.present?
      @default_params
    end

    def set_default_create_params
      @default_params ||= {}
      @default_params.merge! user_id: current_user.id, date: Time.now
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def recollection_params
      params.require(:recollection).permit(:name, :address, :search_by_city, :latitude, :longitude, :goal, :search).merge!(default_params)
    end
end
