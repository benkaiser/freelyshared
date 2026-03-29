class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.string :title, null: false
      t.text :description
      t.string :category, null: false, default: "Other"
      t.boolean :available, null: false, default: true
      t.references :church_member, null: false, foreign_key: true
      t.references :church, null: false, foreign_key: true

      t.timestamps
    end

    add_index :items, :category
    add_index :items, :available
    add_index :items, [ :church_id, :available ]
  end
end
