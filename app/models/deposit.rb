class Deposit < UserTransactionType
  set_table_name 'deposits'
  has_one :user_transaction, :as => :tx
end
