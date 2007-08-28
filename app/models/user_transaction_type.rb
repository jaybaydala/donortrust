class UserTransactionType < ActiveRecord::Base
  validates_presence_of :amount
  validates_numericality_of :amount
  validates_presence_of :user_id

  protected
  def validate
    errors.add("amount", "must be a positive number") if amount && (amount == 0 || amount != amount.abs)
  end

  private
  def create
    return if self.class == self.class.base_class
    id = super
    # create a UserTransaction
    ut_columns = UserTransaction.column_names
    ut_attributes = {}
    attributes.each{|key, val| ut_attributes[key] = val if ut_columns.include?(key)}
    ut = UserTransaction.new(ut_attributes)
    ut.tx = self
    ut.save
    # return the id
    id
  end
end
