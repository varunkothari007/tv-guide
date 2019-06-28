namespace :scrape do
  desc "get array of date for Tv Program data scraping"
  task dates: :environment do
  	puts Transmitter.new.get_scrape_date
  end

  desc "scraping according a date"
	task :tv_data, [:date]  => :environment  do |t, args|
	  args.with_defaults(:message => "Thanks You")
	  if args.date.nil?
	  	Transmitter.new.get_transmitter
	  	Transmitter.new.create_episode_info
	  else
	  	Transmitter.new.get_transmitter("#{args.date}")
	  	Transmitter.new.create_episode_info
	  end
	end

	desc "scraping episode_info"
	task episode_info: :environment  do
	  	Transmitter.new.create_episode_info	
	end

	desc "All Data Scraping"
	task all_data: :environment  do
	  Transmitter.new.scraping_all_data	
	end
end