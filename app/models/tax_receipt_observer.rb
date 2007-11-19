class TaxReceiptObserver < ActiveRecord::Observer
  def after_create(tax_receipt)
    DonortrustMailer.deliver_tax_receipt(tax_receipt)
  end
end