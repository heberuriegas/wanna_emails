class CampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_default_create_params, only: [:create]
  before_action :set_campaign, only: [:show, :edit, :update, :destroy]

  # GET /campaigns
  # GET /campaigns.json
  def index
    @campaigns = Campaign.where(project_id: params[:project_id]).order(id: :desc).page(params[:page])
  end

  # GET /campaigns/1
  # GET /campaigns/1.json
  def show
    @campaign.start if params[:start].present? && @campaign.state_name == :waiting
    @campaign.try_again if params[:try_again].present? && (@campaign.state_name == :failed || params[:force] == 'true')
  end

  # GET /campaigns/new
  def new
    @campaign = Campaign.new
  end

  # GET /campaigns/1/edit
  def edit
  end

  # POST /campaigns
  # POST /campaigns.json
  def create
    @campaign = Campaign.new(campaign_params)

    respond_to do |format|
      if @campaign.save
        format.html { redirect_to project_campaign_path(@project,@campaign), notice: 'Campaign was successfully created.' }
        format.json { render action: 'show', status: :created, location: project_campaign_path(@project,@campaign) }
      else
        format.html { render action: 'new' }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /campaigns/1
  # PATCH/PUT /campaigns/1.json
  def update
    respond_to do |format|
      if @campaign.update(campaign_params)
        format.html { redirect_to project_campaign_path(@project,@campaign), notice: 'Campaign was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /campaigns/1
  # DELETE /campaigns/1.json
  def destroy
    @campaign.destroy
    respond_to do |format|
      format.html { redirect_to project_campaigns_url(@project.id) }
      format.json { head :no_content }
    end
  end

  private
    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_campaign
      @campaign = Campaign.find(params[:id])
    end

    def default_params
      @default_params ||= {}
      @default_params.merge!(project_id: @project.id) unless @campaign.present? and @campaign.project.present?
      @default_params
    end

    def set_default_create_params
      @default_params ||= {}
      @default_params.merge! user_id: current_user.id
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def campaign_params
      params.require(:campaign).permit(:name, :project_id, :user_id, recollection_ids: []).merge!(default_params)
    end
end
