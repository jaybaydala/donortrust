class MilestoneHistoriesController < ApplicationController
  before_filter( :get_milestone )

  # GET /milestone/1/milestone_histories
  # GET /milestone/1/milestone_histories.xml
  def index
    @milestone_histories = @milestone.milestone_histories

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @milestone_histories.to_xml }
    end
  end

  # GET /milestone/1/milestone_histories/1
  # GET /milestone/1/milestone_histories/1.xml
  def show
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @milestone_history.to_xml }
    end
  end

  # GET /milestone/1/milestone_histories/new
  def new
    # prepopulate form with information from @milestone
    #@milestone_history = MilestoneHistory.new
    @milestone_history = MilestoneHistory.new_audit( @milestone )
  end

  # GET /milestone/1/milestone_histories/1;edit
  # how about a 'rollback' option (in milestone_controller?)
#  def edit # possibly want to disable history edit to maintain audit trail
#  end

  # POST /milestone/1/milestone_histories
  # POST /milestone/1/milestone_histories.xml
  def create
    @milestone_history = MilestoneHistory.new(params[:milestone_history])
    # not needed when preset in new_audit
    # @milestone_history.milestone_id = @milestone.id

    respond_to do |format|
      #transactional? save history and update milestone?
      #not specific to here, but what about concurrant update syncronization?
      #make sure record to be updated has not been modified since last read.
      #rails/mysql does not handle automatically.
      #include (hidden) CRC/hash, and if not match reject update?
      #if @milestone_history.save
      if @milestone_history.save_audit( @milestone )
        flash[:notice] = 'Milestone was successfully updated.'
        # use just saved information to update @milestone record
        #format.html { redirect_to milestone_history_url(@milestone, @milestone_history) }
        format.html { redirect_to milestone_url(@milestone) }
        format.xml  { head :created, :location => milestone_history_url(@milestone_history) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @milestone_history.errors.to_xml }
      end
    end
  end

  # PUT /milestone/1/milestone_histories/1
  # PUT /milestone/1/milestone_histories/1.xml
  # do not allow edit / update to history [audit] information
#  def update
#    respond_to do |format|
#      if @milestone_history.update_attributes(params[:milestone_history])
#        flash[:notice] = 'MilestoneHistory was successfully updated.'
#        format.html { redirect_to milestone_history_url(@milestone, @milestone_history) }
#        format.xml  { head :ok }
#      else
#        format.html { render :action => "edit" }
#        format.xml  { render :xml => @milestone_history.errors.to_xml }
#      end
#    end
#  end

  # DELETE /milestone/1/milestone_histories/1
  # DELETE /milestone/1/milestone_histories/1.xml
  # do not want [interactive] history delete: rollback instead?
#  def destroy
#    @milestone_history.destroy
#
#    respond_to do |format|
#      format.html { redirect_to milestone_histories_url }
#      format.xml  { head :ok }
#    end
#  end

  private
  def get_milestone
    @milestone = Milestone.find( params[ :milestone_id ])
    @milestone_history = @milestone.milestone_histories.find(params[:id]) if params[:id]
  end
end
