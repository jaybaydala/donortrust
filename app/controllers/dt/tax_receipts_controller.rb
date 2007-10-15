require 'pdf/writer'
require 'pdf_proxy'
include PDFProxy

class Dt::TaxReceiptsController < DtApplicationController
  before_filter :login_required, :only => [ :printable ]

  def printable
    @receipt = TaxReceipt.find(id=params[:id])
    proxy = create_pdf_proxy(@receipt)
    send_data proxy.render, :filename => proxy.filename, :type => "application/pdf"
    proxy.post_render
  end

  def authorized?
    receipt = TaxReceipt.find(id=params[:id])
    current_user.id == receipt.user.id ? true : false
  end

  def access_denied
    respond_to do |format|
      #(dt_account_path(current_user.id))
      flash[:notice] = "We are sorry, but you can only download your own receipts."
      format.html { redirect_to :controller => 'dt/accounts', :action => 'show', :id => current_user.id }
    end
  end

end
