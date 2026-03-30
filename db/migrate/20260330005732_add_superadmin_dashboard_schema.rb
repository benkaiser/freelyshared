class AddSuperadminDashboardSchema < ActiveRecord::Migration[8.0]
  def change
    # Superadmin flag on church_members
    add_column :church_members, :superadmin, :boolean, default: false, null: false
    # Suspended flag for user management
    add_column :church_members, :suspended, :boolean, default: false, null: false
    add_column :church_members, :suspended_at, :datetime

    # Archived status for churches
    add_column :churches, :archived, :boolean, default: false, null: false
    add_column :churches, :archived_at, :datetime

    # Moderation audit log
    create_table :moderation_actions do |t|
      t.references :actor, null: false, foreign_key: { to_table: :church_members }
      t.string :action_type, null: false
      t.string :target_type, null: false
      t.bigint :target_id, null: false
      t.text :reason
      t.references :church, foreign_key: true
      t.timestamps
    end

    add_index :moderation_actions, [ :target_type, :target_id ]
    add_index :moderation_actions, :action_type

    # Telemetry events
    create_table :telemetry_events do |t|
      t.string :event_type, null: false
      t.references :church, foreign_key: true
      t.references :church_member, foreign_key: true
      t.jsonb :metadata, default: {}
      t.datetime :created_at, null: false
    end

    add_index :telemetry_events, :event_type
    add_index :telemetry_events, :created_at
    add_index :telemetry_events, [ :event_type, :created_at ]
    add_index :telemetry_events, [ :church_id, :event_type, :created_at ], name: "idx_telemetry_church_type_time"
  end
end
