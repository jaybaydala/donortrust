class Dt::EmailUploadsController < DtApplicationController
  
  def new
    respond_to do |format|
      format.html
    end
  end
  
  def create
    emails = if params[:email_upload] && params[:email_upload][:email_file]
      EmailParser.new(params[:email_upload][:email_file], params[:email_upload][:remove_dups] == '1').parse_upload
    else
      []
    end
    
    responds_to_parent do
      render :update do |page|
        if emails.empty?
          page << "$('uploadnotification').innerHTML = '<div class=\"notice\">Please add a file to upload!</div>';"
          page << "$('uploadnotification').highlight();"
        else
          emails.map!(&:to_s)
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