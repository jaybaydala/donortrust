module UserTransactionHelper
  def sum
    amount || 0
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
  
  def amount=(val)
    val = val.to_s.sub(/^\$/, '') if val.to_s.match(/^\$/)
    super(val)
  end

  def save_transaction
    if user_transaction.nil?    
      user_transaction = UserTransaction.new
    end

    user_transaction.user_id = self.participant.user_id
    user_transaction.tx_id = id
    user_transaction.tx_type = self.class.to_s
    user_transaction.save

  end

  private
  def user_transaction_create
    id = self[:id]
    # some of the polymorphic models don't require the user to be logged_in? so don't create an unconnected record
    return if self[:user_id] == nil
    # create a UserTransaction
    ut_columns = UserTransaction.column_names
    ut_attributes = {}
    attributes.each{|key, val| ut_attributes[key] = val if ut_columns.include?(key)}
    ut = UserTransaction.new(ut_attributes)
    ut.tx_id = id
    ut.tx_type = self.class.to_s
    ut.save
  end

  protected
  def validate
    super
    errors.add("amount", "must be a positive number") if !errors.on(:amount) && amount != nil && (amount == 0 || amount != amount.abs)
  end

  def before_validation
    load_card_expiry_from_month_and_year
    super
  end

  def load_card_expiry_from_month_and_year
    self[:card_expiry] = Date.civil(expiry_year, expiry_month) if attribute_names.include?('card_expiry') && !card_expiry? && expiry_year && expiry_month
  end
end
