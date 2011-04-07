class Dt::WallPostsController < DtApplicationController
  before_filter :authorized?, :only => :destroy

  # GET /dt_wall_posts
  # GET /dt_wall_posts.xml

  # this should be embeddable so that we can constantly just render this sucker for
  # ajax action
  def index
    @wall_posts = WallPost.find(:all)
    respond_to do |format|
      format.html { render :layout => false}# index.html.erb
      format.xml  { render :xml => @dt_wall_posts }
    end
  end

  #show
  #new
  #edit

  # POST /dt_wall_posts
  # POST /dt_wall_posts.xml
  def create
    @wall_post = WallPost.new(params[:wall_post])
    @wall_post.author = current_user

    # hackish solution to the polymorphic association, but it allows us to avoid
    # a messy switch case, or anything of that nature. So to add a wall post to something
    # is trivial.
    postable_key = ""
    params.keys.each{|key| postable_key = key unless not key.end_with?'_id'}
    @wall_post.postable_id = params[postable_key]
    @wall_post.postable_type = postable_key[0..postable_key.length-4].classify

    respond_to do |format|
      if @wall_post.save
        flash[:notice] = 'Wall post added!'
        format.html {
          redirect_to url_for([:dt, @wall_post.postable])
        }
        format.xml  { render :xml => @wall_post, :status => :created, :location => @wall_post }
      else
        format.html {
          redirect_to url_for([:dt, @wall_post.postable])
        }
        format.xml  { render :xml => @wall_post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /dt_wall_posts/1
  # DELETE /dt_wall_posts/1.xml
  def destroy
    redirect_url = url_for([:dt, @wall_post.postable])
    @wall_post.destroy
    respond_to do |format|
      flash[:notice] = 'Post was successfully removed.'
      format.html { redirect_to redirect_url }
      format.xml  { head :ok }
    end
  end

  private
  def authorized?
    @wall_post = WallPost.find(params[:id])
    @wall_post.owned?(current_user) || @wall_post.postable.owned?(current_user)
  end

end
