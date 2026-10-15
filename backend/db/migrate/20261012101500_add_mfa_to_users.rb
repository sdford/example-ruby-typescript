class AddMfaToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :otp_secret, :string
    add_column :users, :otp_enabled, :boolean
    add_column :users, :otp_backup_codes, :string, array: true, default: []
    add_index :users, :otp_enabled

    User.find_each { |user| user.update!(otp_enabled: false) }
  end

  def down
    remove_index :users, :otp_enabled
    remove_column :users, :otp_backup_codes
    remove_column :users, :otp_enabled
    remove_column :users, :otp_secret
  end
end
