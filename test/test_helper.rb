# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'excelsior'
require 'active_record'
require 'minitest/autorun'

module MiniTest
  class Spec
    before do
      User.delete_all
    end
  end
end

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
