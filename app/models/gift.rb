class Gift < UserTransactionType
  set_table_name 'gifts'
  has_one :user_transaction, :as => :tx
  validates_presence_of :to_user_id
end
