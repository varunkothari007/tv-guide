class AddFieldS3UrlToEpisode < ActiveRecord::Migration[5.2]
  def change
    add_column :episodes, :s3_url, :string
  end
end
