require 'pdf/writer'
require 'action_view/helpers/number_helper'
include ActionView::Helpers::NumberHelper

PDFTK = "/usr/bin/pdftk"
#PDFTK = nil

module PDFProxy
  def create_pdf_proxy(model)
    if model.kind_of?(TaxReceipt)
      return TaxReceiptPDFProxy.new(model)
    elsif model.kind_of?(Gift)
      return GiftPDFProxy.new(model)
    end
  end
end

class TaxReceiptPDFProxy
  def initialize(receipt)
    @receipt = receipt
  end
  
  def use_pdftk?
    File.exists?(PDFTK) && File.executable?(PDFTK)
  end

  def render(duplicate=true)
    #render_tax_receipt
    pdf = create_pdf(@receipt, duplicate)

    if use_pdftk?
      encrypt(pdf)
    else
      pdf.render
    end
  end

  def post_render
    if use_pdftk?
      # cleans up temp files needed for encryption
      begin
        File.delete("/tmp/#{filename}")
        File.delete("/tmp/#{filename}.orig")
      rescue
        puts 'unable to delete temp files'
      end
    end
  end

  def filename
    return "CFTaxReceipt-#{@receipt.id_display}.pdf"
  end

  protected 
  def create_pdf(receipt, duplicate)
    _pdf = PDF::Writer.new
    _pdf.select_font "Times-Roman"
    _pdf.compressed=true
    i0 = nil
    if duplicate
      i0 = _pdf.image File.dirname(__FILE__) + "/tax_receipt-duplicate.png"
    else
      i0 = _pdf.image File.dirname(__FILE__) + "/tax_receipt.png"
    end
    x = 227
    font_size = 8
    _pdf.add_text(x+14, 639, receipt.id_display, font_size)
    _pdf.add_text(x, 625, number_to_currency(receipt.investment.amount), font_size)
    _pdf.add_text(x, 612, receipt.created_at.to_s(), font_size)
    _pdf.add_text(x, 598, receipt.investment.created_at.to_s(), font_size)
    x2 = 187
    _pdf.add_text(x2, 565, receipt[:first_name] + ' ' + receipt[:last_name], font_size)
    _pdf.add_text(x2, 549, receipt.address, font_size)
    _pdf.add_text(x2, 533, receipt.city, font_size)
    x3 = 367
    _pdf.add_text(x3, 533, receipt.province, font_size)
    _pdf.add_text(x2, 517, receipt.postal_code, font_size)
    _pdf.add_text(x3, 517, receipt.country, font_size)
    return _pdf
  end

  def encrypt(pdf)
    tmpdir = Dir.tmpdir
    forig = File.open("#{tmpdir}/#{filename}.orig", 'w')
    forig.write(pdf.render)
    forig.close()
    password = generate_password
    system("#{PDFTK} #{tmpdir}/#{filename}.orig output #{tmpdir}/#{filename} owner_pw #{password} allow printing")
    f = File.open("#{tmpdir}/" + filename, 'r')
    f.read
  end

  def generate_password
    # generates an unused password in order to encrypt the pdf
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
class GiftPDFProxy

  def initialize(gift)
    @gift = gift
  end

  def render
    create_gift_pdf(@gift).render
  end
  def post_render
  end
  def filename
    return "ChristmasFuture gift card.pdf" 
  end

  protected
  def create_gift_pdf(gift)
      _pdf = PDF::Writer.new
      _pdf.select_font "Times-Roman"
      _pdf.compressed=true
      image_path = File.expand_path("#{RAILS_ROOT}/public#{gift.ecard.sub(/\/large\//, '/printable/')}")
      i0 = _pdf.image image_path if File.exists?(image_path)
      # make sure to add text on top of the image! 
      #_pdf.add_text_wrap(85, 145, 500, gift[:pickup_code], 12, :justification=>:right)
      _pdf.add_text(138, 151, gift[:pickup_code], 12)
      return _pdf
  end
end
