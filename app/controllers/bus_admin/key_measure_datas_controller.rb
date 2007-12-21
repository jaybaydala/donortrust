class BusAdmin::KeyMeasureDatasController < ApplicationController
  
  before_filter :login_required
  
  def index
    begin
      @key_measure = KeyMeasure.find(params[:key_measure_id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    respond_to do |format|
      format.html
    end
  end
  
  def show
    begin
      @key_measure_data = KeyMeasureData.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    respond_to do |format|
      format.html
    end
  end
  
  def new
    @key_measure_data = KeyMeasureData.new
    @key_measure_data.key_measure_id = params[:key_measure_id]
    respond_to do |format|
      format.html
    end
  end
  
  def create
    @key_measure_data = KeyMeasureData.new(params[:key_measure_data])
    @key_measure_data.key_measure_id = params[:key_measure_id]
    @success = @key_measure_data.save
    if @success
      flash[:notice] = "Successfully saved the key measure data."
      respond_to do |format|
        format.html {redirect_to(bus_admin_project_key_measure_url(@key_measure_data.key_measure.project_id, @key_measure_data.key_measure))}
      end
    else
      flash[:error] = "An error occurred while saving the key measure data."
      respond_to do |format|
        format.html {redirect_to(bus_admin_project_key_measures_new_key_measure_data_url(@key_measure_data.key_measure.project_id, @key_measure_data.key_measure))}
      end
    end
    
  end
  
  def edit
    begin
      @key_measure_data = KeyMeasureData.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    respond_to do |format|
      format.html
    end
  end
  
  def update
    begin
      @key_measure_data = KeyMeasureData.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @success = @key_measure_data.update_attributes(params[:key_measure_data])
    if @success
      flash[:notice] = "Successfully updated the key measure data."
      respond_to do |format|
        format.html {redirect_to(bus_admin_project_key_measure_url(@key_measure_data.key_measure.project_id, @key_measure_data.key_measure))}
      end
    else
      flash[:error] = "An error occurred while updating the key measure data."
      respond_to do |format|
        format.html {redirect_to(bus_admin_project_key_measures_edit_key_measure_data_url(@key_measure_data.key_measure.project_id, @key_measure_data.key_measure, @key_measure_data))}
      end
    end
  end
  
  def destroy
     begin
      @key_measure_data = KeyMeasureData.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @success = @key_measure_data.destroy
    if @success
      flash[:notice] = "Successfully deleted the key measure data."
    else
      flash[:error] = "An error occurred while deleted the key measure data."
    end
    respond_to do |format|
      format.html {redirect_to(bus_admin_project_key_measure_url(@key_measure_data.key_measure.project_id, @key_measure_data.key_measure))}
    end
  end
  
end