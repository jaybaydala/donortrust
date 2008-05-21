module CartHelper
  protected
  def find_cart
    @cart = session[:cart] if session[:cart]
    @cart = Cart.new unless @cart
    @cart
  end
end
