class Dt::EmailUploadsController < DtApplicationController
  include ActionView::Helpers::JavascriptHelper
  
  def new
    respond_to do |format|
      format.html
    end
  end
  
  def create
    emails = EmailParser.new(params[:email_upload][:email_file]).parse_upload
    responds_to_parent do
      render :update do |page|
        if emails.empty?
          page << "$('uploadnotification').innerHTML = '<div class=\"notice\">Please add a file to upload!</div>';"
          page << "$('uploadnotification').highlight();"
        else
          emails.collect!{|email| escape_javascript(email.to_s) }
          page << "emails = '';"
          page << "if($('recipients').value != '') emails += $('recipients').value + ', ';"
          page << "emails += '#{emails.join(',\n')}';"
          page << "$('recipients').value=emails;"
          page << "$('uploadnotification').innerHTML = '<div class=\"notice\">Your file has been successfully uploaded!</div>';"
          page << "$('uploadnotification').highlight();"
        end
      end
    end
  end
end