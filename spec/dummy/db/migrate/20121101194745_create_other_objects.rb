class CreateOtherObjects < ActiveRecord::Migration
  def change
    create_table :other_objects do |t|
      t.references :sample_object
      t.string :foo_var
      t.string :bar_lee
      t.timestamps
    end
  end
end
