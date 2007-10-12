require 'pdf/writer'
require 'pdf_factory'
include PDFFactory

class Dt::TaxReceiptsController < DtApplicationController
  before_filter :login_required, :only => [ :printable ]

  def printable
    @receipt = TaxReceipt.find(id=params[:id])
    _pdf = PDFFactory.create_tax_receipt_pdf(@receipt)

    #had to create a temp files, b/c I don't know how to stream to system function
    # once pdftk is installed, set the full path here: 
    # pdftk = "/usr/bin/pdftk"
    pdftk = nil
    if pdftk
      @filename = "CFTaxReceipt-#{@receipt.id_display}.pdf"
      forig = File.open("/tmp/" + @filename + ".orig", 'w')
      forig.write(_pdf.render)
      forig.close()
      password = generate_password
      system("pdftk /tmp/#{@filename}.orig output /tmp/#{@filename} owner_pw #{password} allow printing")
      f = File.open("/tmp/" + @filename, 'r')
      send_data f.read, :filename => "CFTaxReceipt-#{@receipt.id_display}.pdf", :type => "application/pdf"
      f.close()
      File.delete("/tmp/#{@filename}")
      File.delete("/tmp/#{@filename}.orig")
    else
      send_data _pdf.render, :filename => "CFTaxReceipt-#{@receipt.id_display}.pdf", :type => "application/pdf"
    end
  end

  private
  def generate_password
    hash = ""
    srand()
    (1..12).each do
      rnd = (rand(2147483648)%36) # using 2 ** 31
      rnd = rnd<26 ? rnd+97 : rnd+22
      hash = hash + rnd.chr
    end
    hash
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
