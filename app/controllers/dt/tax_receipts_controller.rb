require 'pdf/writer'
class Dt::TaxReceiptsController < DtApplicationController
  before_filter :login_required, :only => [ :printable ]

  # say something nice, you goof!  something sweet.
  def printable
    @receipt = TaxReceipt.find(id=params[:id])
    _pdf = PDF::Writer.new
    _pdf.select_font "Times-Roman"
    _pdf.compressed=true
    i0 = _pdf.image File.dirname(__FILE__) + "/cf_tax_receipt.jpg"
    # TODO: re-align once final receipt template is received
    x = 100
    _pdf.add_text(x, 151, @receipt[:first_name] + ' ' + @receipt[:last_name], 12)
    _pdf.add_text(x, 141, @receipt.investment.amount, 12)
    _pdf.add_text(x, 131, @receipt.created_at.to_s(:short), 12)
    _pdf.add_text(x, 121, @receipt.investment.created_at.to_s(:short), 12)
    _pdf.add_text(x, 111, @receipt.address, 12)
    _pdf.add_text(x, 101, @receipt.city, 12)
    _pdf.add_text(x, 91, @receipt.province, 12)
    _pdf.add_text(x, 81, @receipt.postal_code, 12)
    _pdf.add_text(x, 71, @receipt.country, 12)
    #_pdf.encrypt(user_pass='something', owner_pass='something else', permissions=[:print])
    send_data _pdf.render, :filename => "CFTaxReceipt-#{@receipt.id_display}.pdf", :type => "application/pdf"
  end


end
