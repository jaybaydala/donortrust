class CreditCard
  def self.clean_num(cc)
    return cc.to_s.gsub(/[^0-9]+/, '')
  end
  
  def self.cc_type(cc)
    cc = CreditCard.clean_num(cc)\

    # Get card type based on prefix and length of card number 
    return "VISA"   if cc.match(/^4(.{12}|.{15})$/) 
    return "MC"     if cc.match(/^5[1-5].{14}$/) 
    return "AMX"    if cc.match(/^3[47].{13}$/) 
    return "DC"     if cc.match(/^3(0[0-5].{11}|[68].{12})$/)	#'Diners Club/Carte Blanche'
    return "DSC"    if cc.match(/^6011.{12}$/)	#'Discover Card'
    return "DC"     if cc.match(/^(3.{15}|(2131|1800).{11})$/)	#'JCB'
    return "ENROUT" if cc.match(/^(2(014|149).{11})$/)	#'enRoute'
    return "UNKNOWN" 
  end
  
  def self.valid?(cc)
    sum, digits = 0, 0
    cc = CreditCard.clean_num(cc).reverse
    # VALIDATION ALGORITHM 
    # Loop through the number one digit at a time 
    # Double the value of every second digit (starting from the right) 
    # Concatenate the new values with the unaffected digits 
    digits = ""
    ndx = 0
    cc.scan(/./) {|c|
      digits += (ndx % 2 == 1 ? c.to_i * 2 : c).to_s
      ndx+=1
    }
     
    # Add all of the single digits together 
    sum = 0
    digits.scan(/./) {|d|
      sum += d.to_i
    }

    # Valid card numbers will be transformed into a multiple of 10 
    return sum%10 == 0 ? true : false
  end
  
  def self.is_valid(cc)
    CreditCard.valid?
  end
end
