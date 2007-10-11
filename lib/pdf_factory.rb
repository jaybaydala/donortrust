require 'pdf/writer'

module PDFFactory
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
