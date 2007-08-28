class Investment < UserTransactionType
  set_table_name 'investments'
  has_one :user_transaction, :as => :tx
  validates_presence_of :project_id
end
