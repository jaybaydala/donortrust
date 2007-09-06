module UserTransactionHelper
  def after_create
    id = self[:id]
    # create a UserTransaction
    ut_columns = UserTransaction.column_names
    ut_attributes = {}
    attributes.each{|key, val| ut_attributes[key] = val if ut_columns.include?(key)}
    ut = UserTransaction.new(ut_attributes)
    ut.tx_id = id
    ut.tx_type = self.class.to_s
    #ut.tx = self
    ut.save
    # return the id
    id
  end

  protected
  def validate
    super
    errors.add("amount", "must be a positive number") if amount != nil && (amount == 0 || amount != amount.abs)
  end
end
