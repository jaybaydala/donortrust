class Dt::MdgsController < ApplicationController
  def index
    @goals = MillenniumGoal.find(:all)
  end

  def show
    @goal = MillenniumGoal.find(params[:id]) if MillenniumGoal.exists?(params[:id])
    respond_to do |format|
      format.html {render :layout => 'dt/plain'}
    end
  end
end
