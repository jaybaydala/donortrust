class BusAdmin::KeyMeasuresController < ApplicationController
  
  before_filter :login_required
  
  #MP - Stupid little class so that I can
  #represent true/false as Yes/No
  #values in a dropdown and have Yes/No 
  #map back to true/false. Probably a better way ...
  class BooleanLookupOption
      
      attr_accessor :display, :value
      
      def initialize(display, value)
        super()
        self.display = display
        self.value = value
      end
      
      def self.true
        @@true ||= @@true = self.new("Yes", true)
      end
      
      def self.false
        @@false ||=  @@false = self.new("No", false)
      end
  end
  
  def index
    begin
      @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    respond_to do |format|
      format.html
    end
  end
  
  def new
    @key_measure = KeyMeasure.new
    @key_measure.project_id = params[:project_id]
    @measures = Measure.find(:all)
    @millennium_goals = MillenniumGoal.find(:all)
    @decrease_options = [BooleanLookupOption.true, BooleanLookupOption.false]
    respond_to do |format|
      format.html
    end
  end
  
  def create
    @key_measure = KeyMeasure.new(params[:key_measure])
    goals_selected = params[:millennium_goals]
    @key_measure.project_id = params[:project_id]
    if goals_selected && goals_selected.length > 0
      goals_selected.each { |g| @key_measure.millennium_goals << MillenniumGoal.find(g) }
    end
    @success = @key_measure.save
    if @success
      flash[:notice] = "Successfully saved the key measure."
      respond_to do |format|
        format.html {redirect_to(bus_admin_project_key_measures_url(@key_measure.project_id))}
      end
    else
      flash[:error] = "An error occurred while attempting to save the key measure."
      respond_to do |format|
        format.html {redirect_to(bus_admin_project_new_key_measure_url(@key_measure.project_id))}
      end
    end
    
  end
  
  def edit
    begin
      @key_measure = KeyMeasure.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @measures = Measure.find(:all)
    @millennium_goals = MillenniumGoal.find(:all)
    @decrease_options = [BooleanLookupOption.true, BooleanLookupOption.false]
    respond_to do |format|
      format.html
    end
  end
  
  def update
    begin
      @key_measure = KeyMeasure.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @success = @key_measure.update_attributes(params[:key_measure])
    goals_selected = params[:millennium_goals]
    @key_measure.millennium_goals.clear
    if goals_selected && goals_selected.length > 0
      goals_selected.each { |g| @key_measure.millennium_goals << MillenniumGoal.find(g) }
    end
    if @success
      flash[:notice] = "Successfully updated the key measure."
      respond_to do |format|
        format.html {redirect_to(bus_admin_project_key_measures_url(@key_measure.project_id))}
      end
    else
      flash[:error] = "An error occurred while attempting to update the key measure."
      respond_to do |format|
        format.html {redirect_to(bus_admin_project_edit_key_measure_url(@key_measure.project_id, @key_measure))}
      end
    end
  end
  
  def destroy
    begin
      @key_measure = KeyMeasure.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @success = @key_measure.destroy
    if @success
      flash[:notice] = "Successfully deleted the key measure."
    else
      flash[:error] = "An error occurred while attempting to delete the key measure."
    end
    respond_to do |format|
      format.html {redirect_to(bus_admin_project_key_measures_url(@key_measure.project_id))}
    end
  end
  
  def show
    begin
       @key_measure = KeyMeasure.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    respond_to do |format|
      format.html
    end
  end
end
