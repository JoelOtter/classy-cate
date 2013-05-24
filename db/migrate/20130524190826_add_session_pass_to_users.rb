class AddSessionPassToUsers < ActiveRecord::Migration
  def change
    add_column :users, :session_pass, :string
  end
end
