require 'pdf/writer'
require 'action_view/helpers/number_helper'
include ActionView::Helpers::NumberHelper

class Dt::TaxReceiptsController < DtApplicationController
  before_filter :login_required, :only => [ :printable ]

  def printable
    @receipt = TaxReceipt.find(id=params[:id])
    _pdf = PDF::Writer.new
    _pdf.select_font "Times-Roman"
    _pdf.compressed=true
    i0 = _pdf.image File.dirname(__FILE__) + "/tax_receipt-duplicate.png"
    x = 227
    font_size = 8
    _pdf.add_text(x+14, 639, @receipt.id_display, font_size)
    _pdf.add_text(x, 625, number_to_currency(@receipt.investment.amount), font_size)
    _pdf.add_text(x, 612, @receipt.created_at.to_s(), font_size)
    _pdf.add_text(x, 598, @receipt.investment.created_at.to_s(), font_size)
    x2 = 187
    _pdf.add_text(x2, 565, @receipt[:first_name] + ' ' + @receipt[:last_name], font_size)
    _pdf.add_text(x2, 549, @receipt.address, font_size)
    _pdf.add_text(x2, 533, @receipt.city, font_size)
    x3 = 367
    _pdf.add_text(x3, 533, @receipt.province, font_size)
    _pdf.add_text(x2, 517, @receipt.postal_code, font_size)
    _pdf.add_text(x3, 517, @receipt.country, font_size)

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



end
