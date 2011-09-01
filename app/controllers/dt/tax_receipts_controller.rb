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
        if @receipt
          render :text => tax_receipt_path(@receipt, @receipt.view_code, :format => :pdf)
        else
          flash[:notice] = "We are sorry, but you can only download your own receipts."
          redirect_to(:controller => 'dt/accounts', :action => 'show', :id => current_user.id) and return if logged_in?
          redirect_to(dt_projects_path) and return
        end
      }
      format.pdf {
        raise ActiveRecord::RecordNotFound unless @receipt
        pdf = create_pdf_proxy(@receipt)
        send_data pdf.render, :filename => pdf.filename, :type => "application/pdf"
        pdf.post_render
      }
    end
  end

  def authorized?
    return false unless logged_in?
    current_user.id == @receipt.user.id
  end
end
