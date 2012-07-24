class Dt::FeedbacksController < DtApplicationController
  # POST /feedbacks
  # POST /feedbacks.xml
  def create
    @feedback = Feedback.new(params[:feedback])
    @feedback.user = current_user if logged_in?

    respond_to do |format|
      if verify_recaptcha(:model => @feedback, :message => "There was a ReCaptcha error. Please retry entering the words below") && @feedback.save
        format.json { render :json => { :success => true } }
      else
        # render_to_string(:partial => 'dt/feedbacks/_form') gave an error:
        # ActionView::MissingTemplate (Missing template _form.erb in view path ):
        format.json { render :json => { :success => false, :html => render_to_string(:file => 'dt/feedbacks/_form.html.erb') } }
      end
    end
  end
end
