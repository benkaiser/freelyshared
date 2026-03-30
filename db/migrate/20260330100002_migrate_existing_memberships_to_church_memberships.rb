class MigrateExistingMembershipsToChurchMemberships < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      INSERT INTO church_memberships (church_member_id, church_id, admin, approval_status, is_registrant, joined_at, created_at, updated_at)
      SELECT id, church_id, admin, approval_status, is_registrant, created_at, NOW(), NOW()
      FROM church_members
      WHERE church_id IS NOT NULL
    SQL
  end

  def down
    execute "DELETE FROM church_memberships"
  end
end
