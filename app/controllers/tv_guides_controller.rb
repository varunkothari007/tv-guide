class TvGuidesController < ApplicationController
  def index
  	@transmitters = Transmitter.all

  	@episode = Episode.all
  end
end
