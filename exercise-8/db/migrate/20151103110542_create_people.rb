class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :FirstName
      t.string :LastName
      t.string :Email
      t.integer :Phone
      t.text :Other

      t.timestamps null: false
    end
  end
end
