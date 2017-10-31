class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string    :email, :limit => 320, :null => false
      t.column    :password_hash, 'CHAR(64) CHARACTER SET latin1 COLLATE latin1_swedish_ci', :null => false
      t.column    :password_salt, 'CHAR(64) CHARACTER SET latin1 COLLATE latin1_swedish_ci', :null => false
      t.string    :role, :null => false, :limit => 1, :default => 's'
      t.string    :given_name,
                  :family_name, :null => false
      t.string    :address_street,
                  :address_locality,
                  :address_region
      t.string    :address_postal_code, :limit => 20
      t.string    :address_country, :limit => 2
      t.string    :phone_voice,
                  :phone_mobile, :limit => 50
      t.text      :profile, :limit => 5592405   # number of 3 byte characters in a mediumtext field
      t.string    :time_zone, :null => false, :limit => 30, :default => 'London'
      t.string    :activation_code, :limit => 8
      t.string    :temporary_password
      t.datetime  :temporary_password_expires_at
      t.string    :status, :limit => 15, :null => false
      t.datetime  :last_seen_at
      t.string    :photo_file_name
      t.string    :photo_content_type
      t.integer   :photo_file_size, :unsigned => true
      t.datetime  :photo_updated_at
      t.string    :instructor_photo_file_name
      t.string    :instructor_photo_content_type
      t.integer   :instructor_photo_file_size, :unsigned => true
      t.datetime  :instructor_photo_updated_at
      t.timestamps
    end

    # Create partial index on email (otherwise index would be too big)
    execute 'CREATE INDEX `idx_email` ON `users` (`email`(100));'

  end

  def self.down
    drop_table :users
  end
end
