class CreateEpisodes < ActiveRecord::Migration[5.2]
  def change
    create_table :episodes do |t|
    	t.references :program, index: true
    	t.date :program_date
    	t.time :start_time
    	t.time :end_time
    	t.string :duration
    	t.string :source_url
    	t.string :preview_video_url
    	t.boolean :is_scraped, default: false
    	t.boolean :active, default: true
      t.timestamps 
    end
  end
end