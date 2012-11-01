class CreateApiSampleObjects < ActiveRecord::Migration
  def change
    create_table :sample_objects do |t|
      t.integer :age
      t.integer :weight
      t.integer :height
      t.string  :name
      t.string  :gender

      t.timestamps
    end
  end
end
