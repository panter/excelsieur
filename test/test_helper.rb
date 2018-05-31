$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "excelsior"
require 'active_record'
require "minitest/autorun"

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: File.dirname(__FILE__) + '/test.sqlite3'
)

ActiveRecord::Schema.define version: 0 do
  create_table :users, force: true do |t|
    t.column :first_name, :string
    t.column :last_name, :string
    t.column :email, :string
    t.column :admin, :boolean
  end
end
