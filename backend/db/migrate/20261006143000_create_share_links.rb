class CreateShareLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :share_links do |t|
      t.references :project, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.string :token, null: false
      t.datetime :expires_at
      t.integer :view_count, null: false, default: 0
      t.timestamps
    end

    create_table :share_link_views do |t|
      t.bigint :share_link_id, null: false
      t.string :ip_address
      t.string :user_agent
      t.timestamps
    end
  end
end
