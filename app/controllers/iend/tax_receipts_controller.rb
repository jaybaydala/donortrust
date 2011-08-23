class Iend::TaxReceiptsController < DtApplicationController
  def index
    @tax_receipts = current_user.tax_receipts.paginate(:page => params[:page], :order => "updated_at DESC")
  end
end