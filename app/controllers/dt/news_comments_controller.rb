class Dt::NewsCommentsController < DtApplicationController
  # GET /dt_news_comments
  # GET /dt_news_comments.xml
  def index
    @dt_news_comments = NewsComment.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dt_news_comments }
    end
  end

  # GET /dt_news_comments/1
  # GET /dt_news_comments/1.xml
  def show
    @news_comment = NewsComment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @news_comment }
    end
  end

  # GET /dt_news_comments/new
  # GET /dt_news_comments/new.xml
  def new
    @news_comment = NewsComment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @news_comment }
    end
  end

  # GET /dt_news_comments/1/edit
  def edit
    @news_comment = NewsComment.find(params[:id])
  end

  # POST /dt_news_comments
  # POST /dt_news_comments.xml
  def create
    @news_comment = NewsComment.new(params[:news_comment])
    @news_comment.author = current_user
    @news_item = NewsItem.find(params[:news_item_id])
    @news_comment.news_item = @news_item
    respond_to do |format|
      if @news_comment.save
        flash[:notice] = 'Comment was successfully posted.'
      else
        format.html { render :action => "new" }
      end
      format.html { redirect_to url_for([:dt,@news_item]) }
    end
  end

  # PUT /dt_news_comments/1
  # PUT /dt_news_comments/1.xml
  def update
    @news_comment = NewsComment.find(params[:id])

    respond_to do |format|
      if @news_comment.update_attributes(params[:news_comment])
        flash[:notice] = 'Dt::NewsComment was successfully updated.'
        format.html { redirect_to(@news_comment) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @news_comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /dt_news_comments/1
  # DELETE /dt_news_comments/1.xml
  def destroy
    @news_comment = NewsComment.find(params[:id])
    @news_comment.destroy

    respond_to do |format|
      format.html { redirect_to(dt_news_comments_url) }
      format.xml  { head :ok }
    end
  end
end
