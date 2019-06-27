class TvGuidesController < ApplicationController
  def index
  	@transmitters = Transmitter.paginate(page: params[:page], per_page: 20)

  	@episode = Episode.paginate(page: params[:page], per_page: 30)
  end
end
