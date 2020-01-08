class AddBioToAuthors < ActiveRecord::Migration[6.0]
  def change
    add_column :authors, :bio, :text, null: true, default: nil
    add_column :authors, :gh_issue_number, :integer, null: true, default: nil
    add_column :authors, :gh_last_sync, :timestamp, null: true, default: nil
  end
end
