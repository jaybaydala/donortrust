require 'rexml/document'

module FromXmlBuilder
  
  def self.from_xml(xml)
    xml = REXML::Document.new(xml) if xml.class == String

    ar = self.new
    xml.elements[1].elements.each do | ele |
      sym = ele.name.underscore.to_sym
      # An association
      if ele.has_elements?
        klass = self.reflect_on_association(sym).klass
        ar.__send__(sym) << klass.from_xml(ele)
  
      # An attribute
      else
        ar[sym] = ele.text
      end
    end

    return ar
  end
end