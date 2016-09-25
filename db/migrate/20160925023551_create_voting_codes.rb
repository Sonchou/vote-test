class CreateVotingCodes < ActiveRecord::Migration
  def change
    create_table :voting_codes do |t|
      t.string :voteid
      t.string :auth
      t.boolean :enabled, :null => false, :default => true

      t.timestamps null: false
    end
  end
end
