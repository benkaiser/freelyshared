class AddRequireAdminApprovalToChurches < ActiveRecord::Migration[8.0]
  def change
    add_column :churches, :require_admin_approval, :boolean, default: false, null: false
  end
end
