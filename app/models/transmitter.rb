class Transmitter < ApplicationRecord
	has_many :programs, dependent: :destroy
	validates_presence_of :name
	after_create :save_cid

	require 'open-uri'

	# def past_days
	# 	Time.now - 1
	# end
	def save_cid
		cid_no = Random.rand(1...100)
		self.update(cid: cid_no) rescue nil
	end

	# Will get the dates that we have to scrape.
	def get_scrape_date
		dates = []
		for i in -2..6 do
		  dates << (Time.now + i.day).strftime("%Y-%m-%d")
		end
		dates
	end

	# Will scrape all the dates data 2 past days, 1 today, 4 next days.
	def scraping_all_data
		get_scrape_date.each do |date|
			get_transmitter(date)
		end
		create_episode_info
		Episode.upload_preview_at_s3
	end

	# def get_transmitter(date=nil)
	# 	i = 0
	# 	stop = false
	# 	date = Time.now.strftime("%Y-%m-%d") if date.nil?
	# 	until stop do
	# 		# url  =  "https://www.tvspielfilm.de/tv-programm/sendezeit/?page=#{i}&date=2019-06-27"
	# 		url  =  "https://www.tvspielfilm.de/tv-programm/sendezeit/?page=#{i}&date=#{date}"
	# 		doc = send_request(url)
	#     data =  doc.css('div.program-channel ul.channel-list li a')
	#     stop = true unless data.present?
	# 		transmitters = []
	#     data.each do |d|
	#     	name = d.attributes['title'].value
	#       transmitters << name[0..name.length-10]
	#     end
	#   	get_programs(transmitters, doc, date)
	#     i+=1
	#     puts "page no. #{i}"
	#   end
	# end

	# def get_programs(transmitters, doc, date)
	#   data = doc.css('div.program-info ul.program-info-list li.uslisting')
	# 	i = 0
 #    	print "[#"
 #    data.css("ul.channel-list").each do |list|
 #    	transmitter = Transmitter.where(name: transmitters[i]).first_or_initialize
 #    	transmitter.save
 #    	list.css("li").each do |pro|
 #    		begin
 #      		name = pro.css("div.topholder a.aholder").text
 #      		href = pro.css("div.topholder a.aholder")[0].attributes["href"].value rescue nil
 #      		time = pro.css("spanclass").text
 #      		next unless (time.present? && href.present? && name.present?)
 #      		time = time.delete(" ").split("-")
 #      		program  = Program.where(name: name ).first_or_initialize
 #      		program.update(transmitter_id: transmitter.id)
	# 				ep = Episode.where(source_url: href).first_or_initialize
	# 				ep.update(program_id: program.id , start_time: time[0], end_time: time[1] ,program_date: date ,source_url: href, duration: get_duration(time))
 #    		rescue Exception => e
 #    			puts e
 #    		end
 #    	end
 #    	i+=1
 #    	print "#"
 #  	end
 #  	print "#] 100%"
 #  	puts " Program count==> #{Program.count}"
 #  	puts " Transmitter count==> #{Transmitter.count}"
 #  	puts " Episode count==> #{Episode.count}"
	# end

	def get_duration(time)
		# min =  (Time.parse(time[1]).to_i - Time.parse(time[0]).to_i)/60 rescue nil
		s_time = Time.parse(time[0]).to_i
		e_time = Time.parse(time[1]).to_i
		e_time = (Time.parse(time[1]) + 1.day).to_i if ((e_time - s_time) < 0)
		min =  (e_time - s_time)/60 rescue nil
		return min  
	end

	# Method used to scrape the detail information of episode.
	def create_episode_info
		ep = Episode.where(is_scraped: false)
		puts "Left Episode ==> #{ep.count}"
		print = "[#"
		i = 0
		ep.each do |epis|
			epis.get_episode_info
			print "#"
			i+=1
			puts "{ 100 done }" if 100 == i
		end
		print = "#] Done "
	end

	def send_request(url)
	  Nokogiri::HTML(open(url))
	end

	# Method used to scrape the transmitter information.
	def get_transmitter(date=nil)
		i = 1
		stop = false
		date = Time.now.strftime("%Y-%m-%d") if date.nil?
		puts "Date. #{date}"
		until stop do
			begin
				url =  "https://www.tvspielfilm.de/tv-programm/sendungen/?page=#{i}&order=time&date=#{date}"
				doc = send_request(url)
				rows = doc.css("table.info-table tr")
				j = 0
				rows.first(5).each do |row|	
					j+=1
					next if j == 1
					#transmitter
					tv_title  		= row.css(".programm-col1 a").first.attributes["title"].value 
					tv_href  			= row.css(".programm-col1 a").first.attributes["href"].value
					tv_name				= tv_title[0..tv_title.length-10]
					#Program
					name 					= row.css(".col-3 strong a").first.text #name:
					genre 				= row.css(".col-4 span").first.text #genre:
					branch 				= row.css(".col-5 span").first.text.delete(" \n\t")
					#Episode  source_url: preview_video_url: 
					program_date	= date #program_date
					time 					= row.css(".col-2 strong")[0].text #start_time: end_time: duration:
					time          = time.delete(" ").split("-")
					source_url 		= row.css(".col-3 strong a").first.attributes['href'].value

					transmitter = Transmitter.where(name: tv_name, tv_url: tv_href, title: tv_title).first_or_initialize
					transmitter.save 

					program 		= Program.where(name: name , transmitter_id: transmitter.id, genre: genre, branch: branch ).first_or_initialize
					program.save

					episode 		= Episode.where(program_id: program.id, source_url: source_url, start_time: time[0]).first_or_initialize
					episode.update(program_date: program_date, start_time: time[0], end_time: time[1], duration: get_duration(time))
				end
				i+=1
			rescue Exception => e
				Rails.logger.info e
				break
			end
			
			Rails.logger.info "page no. #{i}"
			Rails.logger.info " Program count==> #{Program.count}"
			Rails.logger.info " Transmitter count==> #{Transmitter.count}"
			Rails.logger.info " Episode count==> #{Episode.count}"
		end
	end
end
