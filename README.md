# README

Please ask them to follow below steps to setup application :
1) Install ruby version : 2.5.1

2) Install the postges (psql : version 10.8)

3) Unzip the project folder and go to application path.

4) open the config/database.yml and set the postgres password

5) To install all required gems/plugins
  $ bundle install

6) To create the database and load the table structure.
  $ rake db:create rake db:migrate

7) Now open the console to scrape the data for all transmitter and there program.
  $ Transmitter.new.get_transmitter 

8) Now run another command to scrape the program details.
  $ Transmitter.new.create_episode_info

Development mode :
1) For local machine, all set to see the data :) start the server
  $ rails s

2) Go to browser and type:
  http://localhost:3000

Production mode:
Setup the Nginx and Unicorn.