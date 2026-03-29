class AddAdminAndApprovalToChurchMembers < ActiveRecord::Migration[8.0]
  def change
    add_column :church_members, :admin, :boolean, default: false, null: false
    add_column :church_members, :approval_status, :string, default: "approved", null: false

    add_index :church_members, [ :church_id, :approval_status ]
  end
end
