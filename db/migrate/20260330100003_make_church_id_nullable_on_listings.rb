class MakeChurchIdNullableOnListings < ActiveRecord::Migration[8.0]
  def change
    change_column_null :church_members, :church_id, true
    change_column_null :items, :church_id, true
    change_column_null :needs, :church_id, true
    change_column_null :services_listings, :church_id, true
  end
end
