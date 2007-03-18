class MilestonesController < ApplicationController
  # GET /milestones
  # GET /milestones.xml
  def index
    @milestones = Milestone.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @milestones.to_xml }
    end
  end

  # GET /milestones/1
  # GET /milestones/1.xml
  def show
    @milestone = Milestone.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @milestone.to_xml }
    end
  end

  # GET /milestones/new
  def new
    @milestone = Milestone.new
  end

  # GET /milestones/1;edit
  def edit
    #redirect edit milestone to new (prepopulated) history form
    @milestone = Milestone.find(params[:id])
    redirect_to new_milestone_history_path(@milestone) # ? param for milestone
  end

  # POST /milestones
  # POST /milestones.xml
  def create
    @milestone = Milestone.new(params[:milestone])

    respond_to do |format|
      if @milestone.save_with_audit
        flash[:notice] = 'Milestone was successfully created.'
        format.html { redirect_to milestone_url(@milestone) }
        format.xml  { head :created, :location => milestone_url(@milestone) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @milestone.errors.to_xml }
      end
    end
  end

  # PUT /milestones/1
  # PUT /milestones/1.xml
  # edit is redirect to [new] history, which does the update as well
#  def update
#    @milestone = Milestone.find(params[:id])
#
#    respond_to do |format|
#      if @milestone.update_attributes(params[:milestone])
#        flash[:notice] = 'Milestone was successfully updated.'
#        format.html { redirect_to milestone_url(@milestone) }
#        format.xml  { head :ok }
#      else
#        format.html { render :action => "edit" }
#        format.xml  { render :xml => @milestone.errors.to_xml }
#      end
#    end
#  end

  # DELETE /milestones/1
  # DELETE /milestones/1.xml
  # only allow delete when new? change status to rejected/cancelled/... instead?
  def destroy
    @milestone = Milestone.find(params[:id])
    # to 'really' delete, need to also/first delete the history records
    #@milestone_histories = @milestone.milestone_histories
    #for milestone_history in @milestone_histories do |mh| mh.destroy
    @milestone.destroy

    respond_to do |format|
      format.html { redirect_to milestones_url }
      format.xml  { head :ok }
    end
  end
end
