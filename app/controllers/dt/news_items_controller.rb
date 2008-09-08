class Dt::NewsItemsController < DtApplicationController
  
   before_filter :find_postable, :only => [:index, :create]
  
  # GET /news_items
  # GET /news_items.xml
  def index
    @news_items = @postable.news_items
    [@news_item,@postable]
  end

  # GET /news_items/1
  # GET /news_items/1.xml
  def show
    @news_item = NewsItem.find(params[:id])
  end

  # GET /news_items/new
  # GET /news_items/new.xml
  def new
    @news_item = NewsItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @news_item }
    end
  end

  # GET /news_items/1/edit
  def edit
    @news_item = NewsItem.find(params[:id])
  end

  # POST /news_items
  # POST /news_items.xml
  def create
    @news_item = NewsItem.new(params[:news_item])
    
    respond_to do |format|
      if @news_item.save
        flash[:notice] = 'NewsItem was successfully created.'
        format.html { redirect_to(@news_item) }
        format.xml  { render :xml => @news_item, :status => :created, :location => @news_item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @news_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def create
    @news_item = NewsItem.new(params[:news_item])
    @news_item.author = current_user
    
    # hackish solution to the polymorphic association, but it allows us to avoid
    # a messy switch case, or anything of that nature. So to add a wall post to something
    # is trivial.
    postable_key = ""
    params.keys.each{|key| postable_key = key unless not key.end_with?'_id'}
    @news_item.postable_id = params[postable_key]
    @news_item.postable_type = postable_key[0..postable_key.length-4].capitalize
    
    
    respond_to do |format|
      if @news_item.save
        flash[:notice] = 'News Added.'
        format.html {
          redirect_to url_for([:manage,:dt, @news_item.postable])
        }
        format.xml  { render :xml => @news_item, :status => :created, :location => @news_item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @news_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /news_items/1
  # PUT /news_items/1.xml
  def update
    @news_item = NewsItem.find(params[:id])
    respond_to do |format|
      if @news_item.update_attributes(params[:news_item])
        flash[:notice] = 'News was successfully updated.'
        format.html { redirect_to(url_for([:dt,@news_item.postable])) }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @news_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /news_items/1
  # DELETE /news_items/1.xml
  def destroy
    @news_item = NewsItem.find(params[:id])
    @news_item.destroy
    redirect_to(url_for([:dt,@news_item.postable]))
  end
  
  
  private
  def find_postable
    # hackish solution to the polymorphic association, but it allows us to avoid
    # a messy switch case, or anything of that nature. So to add a wall post to something
    # is trivial.
    postable_key = ""
    params.keys.each{|key| postable_key = key unless not key.end_with?'_id'}
    @postable = Kernel.const_get(postable_key[0..postable_key.length-4].capitalize).find(params[postable_key])
  end
end
