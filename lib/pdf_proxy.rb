require 'action_view/helpers/number_helper'
include ActionView::Helpers::NumberHelper

PDFTK = "/usr/bin/pdftk"

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
    @use_pdftk ||= File.exists?(PDFTK) && File.executable?(PDFTK)
    RAILS_DEFAULT_LOGGER.warn "PDFTK is unavailable" unless @use_pdftk
    @use_pdftk
  end

  def render(duplicate=true)
    pdf = create_pdf(@receipt, duplicate)

    if use_pdftk?
      encrypt(pdf)
    else
      pdf.render
    end
  end

  def save_to_tmp
    File.open(Rails.root.join('tmp', self.filename), "w") do |f|
      f.write self.render
    end
  end

  def post_render
    if use_pdftk?
      # cleans up temp files needed for encryption
      begin
        File.delete("#{tmpdir}/#{filename}")
        File.delete("#{tmpdir}/#{filename}.orig")
      rescue
        puts 'unable to delete temp files'
      end
    end
  end

  def filename
    return "UEndTaxReceipt-#{@receipt.id_display}.pdf"
  end
  
  def image_file(duplicate)
    image_file = duplicate ? "tax_receipt-duplicate.jpg" : "tax_receipt.jpg"
    image_file = "tax_receipt-void.jpg" unless RAILS_ENV == "production"
    File.dirname(__FILE__) + "/tax_receipts/#{image_file}"
  end

  protected 
  def create_pdf(receipt, duplicate)
    _pdf = PDF::Writer.new
    _pdf.select_font "Helvetica"
    _pdf.compressed=true
    i0 = nil
    i0 = _pdf.image image_file(duplicate)
    x = 227
    font_size = 8
    _pdf.add_text(x+18, 639, receipt.id_display, font_size)    
    if receipt.gift != nil
      _pdf.add_text(x, 625, number_to_currency(receipt.gift.amount), font_size)
      _pdf.add_text(x, 598, receipt.gift.created_at.to_s(), font_size)
    elsif receipt.deposit != nil
      _pdf.add_text(x, 625, number_to_currency(receipt.deposit.amount), font_size)
      _pdf.add_text(x, 598, receipt.deposit.created_at.to_s(), font_size)
    elsif receipt.order != nil
      _pdf.add_text(x, 625, number_to_currency(receipt.order.credit_card_payment), font_size)
      _pdf.add_text(x, 598, receipt.order.created_at.to_s(), font_size)
    else
      _pdf.add_text(x, 625, number_to_currency(receipt.amount), font_size)
      _pdf.add_text(x, 598, receipt.received_on.to_s(), font_size)
    end   
    _pdf.add_text(x, 612, receipt.created_at.to_s(), font_size)
    
    x2 = 187
    x3 = 367
    _pdf.add_text(x2, 565, receipt[:first_name] + ' ' + receipt[:last_name], font_size)
    _pdf.add_text(x2, 549, receipt.address, font_size)
    _pdf.add_text(x2, 533, receipt.city, font_size)
    _pdf.add_text(x3, 533, receipt.province, font_size)
    _pdf.add_text(x2, 517, receipt.postal_code, font_size)
    _pdf.add_text(x3, 517, receipt.country, font_size)
    return _pdf
  end

  def encrypt(pdf)
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
  
  def tmpdir
    @tmpdir ||= Dir.tmpdir
  end
end
class GiftPDFProxy

  def initialize(gift)
    @gift = gift
  end

  def render
    create_pdf.render
  end
  
  def create_pdf
    create_gift_pdf
  end

  def save_to_tmp
    File.open(Rails.root.join('tmp', self.filename), "w") do |f|
      f.write self.render
    end
  end

  def post_render
  end
  
  def filename
    return "UEnd printable gift card.pdf"
  end
  
  protected
  def create_gift_pdf
    _pdf = PDF::Writer.new
    _pdf.select_font "Helvetica"
    _pdf.compressed=true
    image_path = File.expand_path("#{@gift.e_card.printable}") if @gift.e_card_id? && @gift.e_card
    i0 = _pdf.image image_path if image_path && File.exists?(image_path)
    RAILS_DEFAULT_LOGGER.warn "Gift Card Image does not exist: #{image_path}" if image_path.nil? || !File.exists?(image_path)
    # make sure to add text on top of the image! 
    right_pane_boundaries = {:absolute_left => 324, :absolute_right => 594}
    _pdf.add_text(138, 151, @gift.pickup_code, 12)
    _pdf.select_font "Helvetica"
    _pdf.pointer = 396
    _pdf.text(@gift.message.gsub(/\n\n/, "\n"), {:font_size => 10}.merge(right_pane_boundaries)) if @gift.message?
    if @gift.project
      _pdf.select_font "Helvetica-Bold"
      _pdf.pointer = 90
      _pdf.text("This #{number_to_currency(@gift.amount)} gift is being directed to a project:", {:font_size => 10}.merge(right_pane_boundaries))
      _pdf.select_font "Helvetica"
      project_text = "#{@gift.project.name}\nhttp://www.uend.org/dt/project/#{@gift.project_id}"
      _pdf.text(project_text, {:font_size => 10}.merge(right_pane_boundaries))
    end
    return _pdf
  end
end
