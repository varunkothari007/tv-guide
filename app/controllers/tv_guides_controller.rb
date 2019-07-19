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
      sc = Scraping.where(status: false).count 
      if sc<1
    		if Transmitter.new.get_scrape_date.include?(params[:date])
  	  		# session[:scrape] = { start: true, date: params[:date] }
          Scraping.create({which_date: params[:date], status: false})
  	  		ScrapeJob.perform_async(params[:date])
          @msg = "Scrapping started for date #{params[:date]}."
  	  	else
          @msg = "Given date #{params[:date]} in not in scrapping range, Either past 2 days or next 5 days."
  	  		# session[:scrape] = { start: false, date: params[:date] }
  	  	end
      else
        @msg = "Scrapping running, Please wait to complete date."
      end
  	end
	  # redirect_to root_path
  end
end
