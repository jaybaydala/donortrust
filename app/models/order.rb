class Order < ActiveRecord::Base
  

  def self.personal_donor
    "personal"
  end
  def self.corporate_donor
    "corporate"
  end
  
  def credit_card_concealed
    "**** **** **** #{credit_card.to_s[-4, 4]}"
  end
  
  def account_balance_total=(val)
    val = val.to_s.sub(/^\$/, '') if val.to_s.match(/^\$/)
    super(val)
  end
  def credit_card_total=(val)
    val = val.to_s.sub(/^\$/, '') if val.to_s.match(/^\$/)
    super(val)
  end
  def amount=(val)
    val = val.to_s.sub(/^\$/, '') if val.to_s.match(/^\$/)
    super(val)
  end
  
  def complete?
    # authorization_result?
    true
  end
  
  def card_expiry
    load_card_expiry_from_month_and_year
    super
  end
  def card_expiry=(value)
    if value.kind_of?(String)
      if value.match(/^\d\d\d\d$/)
        value = Array[ value[0,2], value[2,2] ]
      elsif value.match(/^\d{1,2}\/(\d\d)|(\d\d\d\d)$/)
        value = value.split('/')
      elsif value.match(/^\d\d \d\d$/)
        value = value.split(' ')
      end
    end
    if value && value.kind_of?(String)
      begin
        tmp = Date.parse(value)
        date = Date.civil(tmp.year, tmp.month, -1)
      rescue ArgumentError
        date = nil
      end
    elsif value && value.kind_of?(Array)
      year = value[1]
      year = (Date.today.year.to_s[0,2] + value[1]) if value[1].length == 2
      date = Date.civil(year.to_i, value[0].to_i, -1)
    elsif value && value.kind_of?(Date)
      tmp = value
      date = Date.civil(tmp.year, tmp.month, -1)
    end
    write_attribute(:card_expiry, date) if date
    return false if !date
  end
  
  attr_accessor :expiry_month, :expiry_year
  def expiry_month
    @expiry_month = card_expiry.month if !@expiry_month && card_expiry?
    @expiry_month
  end
  def expiry_month=(month)
    @expiry_month = month.to_i unless month.nil?
  end
  def expiry_year=(year)
    year = year.to_s
    @expiry_year = (Date.today.year.to_s[0,2] + year) if year && year.length == 2
    @expiry_year = (Date.today.year.to_s[0,3] + year) if year && year.length == 1
    @expiry_year = @expiry_year.to_i unless @expiry_year.nil?
  end
  def expiry_year
    @expiry_year = card_expiry.year if !@expiry_year && card_expiry?
    @expiry_year
  end
  
  protected
  def load_card_expiry_from_month_and_year
    self[:card_expiry] = Date.civil(expiry_year, expiry_month) if attribute_names.include?('card_expiry') && !card_expiry? && expiry_year && expiry_month
  end
end