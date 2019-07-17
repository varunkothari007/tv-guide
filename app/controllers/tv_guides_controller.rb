class TvGuidesController < ApplicationController
  def index
  	@transmitters = Transmitter.paginate(page: params[:page], per_page: 20)

  	@episode = Episode.paginate(page: params[:page], per_page: 30)
  end

  def show
  	@episode = Episode.find(params[:id])
  end

  def scrape
  	if params[:date].present? 
  		if Transmitter.new.get_scrape_date.include?(params[:date])
	  		session[:scrape] = { start: true, date: params[:date] }
	  		ScrapeJob.perform_async(params[:date])
	  	else
	  		session[:scrape] = { start: false, date: params[:date] }
	  	end
  	end
	  redirect_to root_path
  end
end
