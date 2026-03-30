class CreateChurchMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :church_memberships do |t|
      t.references :church_member, null: false, foreign_key: true
      t.references :church, null: false, foreign_key: true
      t.boolean :admin, default: false, null: false
      t.string :approval_status, default: "approved", null: false
      t.boolean :is_registrant, default: false, null: false
      t.datetime :joined_at

      t.timestamps
    end

    add_index :church_memberships, [ :church_member_id, :church_id ], unique: true
    add_index :church_memberships, [ :church_id, :approval_status ]
  end
end
