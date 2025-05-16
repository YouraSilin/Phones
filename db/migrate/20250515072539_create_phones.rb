class CreatePhones < ActiveRecord::Migration[7.1]
  def change
    create_table :phones do |t|
      t.string :department
      t.string :name
      t.string :position
      t.string :number
      t.string :mobile
      t.string :email

      t.timestamps
    end
  end
end
