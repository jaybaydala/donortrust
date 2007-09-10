module UserTransactionHelper
  def after_create
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

  def sum
    amount || 0
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
  
  def expiry_month
    self[:card_expiry].month if self[:card_expiry]
  end

  def expiry_year
    self[:card_expiry].year.to_s[-2, 2] if self[:card_expiry]
  end

  protected
  def validate
    super
    errors.add("amount", "must be a positive number") if amount != nil && (amount == 0 || amount != amount.abs)
  end
end
