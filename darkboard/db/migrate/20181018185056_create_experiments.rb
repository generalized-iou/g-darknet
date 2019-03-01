class CreateExperiments < ActiveRecord::Migration[5.2]
  def change
    create_table :experiments do |t|
      t.string :name
      t.string :path
      t.string :subtitle
      t.boolean :is_hidden
      t.integer :last_line_read, default: 0
      t.text :notes
      t.text :chart
      t.text :color

      t.timestamps
    end
  end
end
