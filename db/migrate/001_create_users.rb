class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :login
      t.string :first_name
      t.string :last_name
      t.string :crypted_password
      t.string :salt
      t.string :remember_token
      t.datetime :remember_token_expires_at
      t.timestamps
    end

    #create the experimental administrator
    User.create({
      :login => PersonalInformation::AdminLogin,
      :first_name => "Admin",
      :last_name => "Admin",
      :password => PersonalInformation::AdminPassword
    })
  end

  def self.down
    drop_table :users
  end  
end
