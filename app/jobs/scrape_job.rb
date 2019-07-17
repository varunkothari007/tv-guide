class ScrapeJob 
  # queue_as :default
  include SuckerPunch::Job
   workers 5

  def perform(date)
  	if date.present?
	  	Transmitter.new.get_transmitter(date)
	  	Transmitter.new.create_episode_info
	  end
  end
end