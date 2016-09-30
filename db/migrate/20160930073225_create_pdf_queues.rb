class CreatePdfQueues < ActiveRecord::Migration
  def change
    create_table :pdf_queues do |t|
      t.string :path

      t.timestamps null: false
    end
  end
end
