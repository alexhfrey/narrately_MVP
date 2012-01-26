class AddOutputfileColumnsToProjects < ActiveRecord::Migration
  def self.up
    change_table :projects do |t|
      t.has_attached_file :output_file, :default_url => "/images/missing.png"
    end
  end

  def self.down
    drop_attached_file :projects, :output_file
  end

end
