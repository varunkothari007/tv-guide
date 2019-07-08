class AddVideoFilenameIntoEpisode < ActiveRecord::Migration[5.2]
  def change
    add_column :episodes, :video_filename, :string
  end
end
