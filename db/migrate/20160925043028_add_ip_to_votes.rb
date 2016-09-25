class AddIpToVotes < ActiveRecord::Migration
  def change
    add_column :votes, :ip, :string, :default => "0.0.0.0"
  end
end
