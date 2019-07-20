class ScrapeJob 
  # queue_as :default
  include SuckerPunch::Job
   workers 5

  def perform(date)
  	if date.present?
	  	Transmitter.new.get_transmitter(date)
	  	Transmitter.new.create_episode_info
		Episode.upload_preview_at_s3
		sc = Scraping.where(which_date: date)
		sc.update( status: true )
	  end
  end
end