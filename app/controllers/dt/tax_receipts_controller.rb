require 'pdf/writer'
require 'pdf_proxy'
include PDFProxy

class Dt::TaxReceiptsController < DtApplicationController
  # before_filter :login_required, :only => [ :show ]

  def show
    if params[:code]
      @receipt = TaxReceipt.find_by_id_and_view_code(params[:id], params[:code])
    else params[:id]
      @receipt = TaxReceipt.find(params[:id])
      @receipt = nil unless authorized?
    end
    respond_to do |format|
      format.html {
        unless @receipt
          flash[:notice] = "We are sorry, but you can only download your own receipts."
          redirect_to(:controller => 'dt/accounts', :action => 'show', :id => current_user.id) and return if logged_in?
          redirect_to(dt_projects_path) and return
        end
      }
      format.pdf {
        pdf = create_pdf_proxy(@receipt)
        send_data pdf.render, :filename => pdf.filename, :type => "application/pdf"
        pdf.post_render
      }
    end
  end

  def authorized?
    return false unless logged_in?
    receipt = TaxReceipt.find(params[:id])
    current_user.id == receipt.user.id ? true : false
  end
end
