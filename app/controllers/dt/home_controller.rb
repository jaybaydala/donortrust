class Dt::HomeController < DtApplicationController

  def index
    @carousel_items = CarouselItem.all(:order => 'position, id')
  end

end
