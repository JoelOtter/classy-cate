class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :login
      t.string :email
      t.string :password_hash
      t.string :password_salt
      t.string :session_pass

      t.timestamps
    end
  end
end
