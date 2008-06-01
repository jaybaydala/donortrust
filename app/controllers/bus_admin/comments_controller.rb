class BusAdmin::CommentsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  active_scaffold :comment do |config|
    config.actions.exclude :create,:delete,:update
    config.list.columns = [:name,:email,:comment,:date]
    config.show.columns = [:name,:email,:date,:comment]
  end
  
    verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
  
  def feedback
    render :template => 'bus_admin/comments/feedback'
  end


  def create
    @comment = Comment.new(params[:comment])
    @comment.date = Time.now
    if @comment.save
        flash[:notice] = "Thank you!"
        redirect_to('/bus_admin/home')
    else
       error = "<div id='errorExplanation'>"
     if params[:comment][:name]
       error += "Please enter your <strong>name</strong>. <br />"
     end
     if params[:comment][:email]
       error += "Please enter your <strong>email</strong> address. <br />"
     end
     if params[:comment][:comment]
       error += "Please enter a <strong>comment</strong>. <br />"
     end
     error += "</div>"
      flash[:notice] = error
     redirect_to('/bus_admin/feedback')
   end
  end
  
  
end

