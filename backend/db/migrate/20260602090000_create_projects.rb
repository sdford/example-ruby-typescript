class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.string :address, null: false
      t.text :notes
      t.integer :status, null: false, default: 0
      t.timestamps
    end
    add_index :projects, [:organization_id, :updated_at]

    create_table :measurements do |t|
      t.references :project, null: false, foreign_key: true
      t.string :kind, null: false
      t.decimal :value, precision: 12, scale: 2, null: false
      t.string :unit, null: false
      t.timestamps
    end
  end
end
