module Dt::DepositsHelper
  def obfuscate_credit_card(cc)
    return if cc.nil? || (cc.is_a?(String) && cc.empty?)
    "**** **** **** " + cc.to_s[-4, 4]
  end
end