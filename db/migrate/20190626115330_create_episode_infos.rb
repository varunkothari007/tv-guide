class CreateEpisodeInfos < ActiveRecord::Migration[5.2]
  def change
    create_table :episode_infos do |t|
    	t.references :episode, index: true
    	t.text   :description
    	t.string :country
			t.string :year
			t.string :age_rating
			t.string :director
			t.string :producer
			t.string :script
			t.string :camera
    	t.string :thumb
			t.string :music
			t.string :original_title
			t.jsonb :actors, null: false, default: '{}'
			t.string :image_urls, array: true, default: []
      t.timestamps
    end
  end
end



