require "test_helper"
require "excelsior/import"

class UserImport < Excelsior::Import
  source "test/files/complete.xlsx"

  map "Vorname", to: :first_name
  map "Nachname", to: :last_name
  map "E-Mail", to: :email
end

class User < ActiveRecord::Base
  validates :first_name, presence: true
end

describe Excelsior do
  before do
    @import = UserImport.new
  end

  it 'has a version number' do
    refute_nil ::Excelsior::VERSION
  end

  describe 'source' do
    it 'allows setting the source on the class' do
      import = UserImport.new
      assert_equal "test/files/complete.xlsx", import.source
    end

    it 'allows setting the source on an instance level' do
      import = UserImport.new("test/files/missing-column.xlsx")
      assert_equal "test/files/missing-column.xlsx", import.source
    end
  end

  describe '#rows' do
    it 'returns the correct number of rows' do
      assert_equal 2, @import.rows.length
    end
  end

  describe '#columns' do
    it 'returns the columns as defined in the excel' do
      assert_equal 3, @import.columns.length
      assert_equal "E-Mail", @import.columns[0]
      assert_equal "Vorname", @import.columns[1]
      assert_equal "Nachname", @import.columns[2]
    end
  end

  describe '#fields' do
    it 'returns the mapped fields' do
      assert_equal @import.fields, [
        { attribute: :first_name, header: "Vorname" },
        { attribute: :last_name, header: "Nachname" },
        { attribute: :email, header: "E-Mail" }
      ]
    end
  end

  describe '#run' do
    describe 'without a block' do
      it 'inserts the records' do
        @import.run
        assert_equal User.all.size, 2
      end
    end

    describe 'with a block' do
      it 'yields the records to the block' do
        results = @import.run { |v| v }
        assert_equal results[0], {
          first_name: "Hans",
          last_name: "Müller",
          email: "hans@mueller.com"
        }
        assert_equal results[1], {
          first_name: "Jögi",
          last_name: "Brunz",
          email: "jb@runz.com"
        }
      end
    end
  end

  describe '#errors' do
    it 'returns an error when a column is missing in the excel' do
      import = UserImport.new("test/files/missing-column.xlsx")
      assert import.errors[:missing_column].any?
    end

    it 'returns the model validation errors' do
      import = UserImport.new("test/files/missing-first-name.xlsx").tap(&:run)
      assert import.errors[:model].any?
      assert_equal import.errors[:model], [Excelsior::Error.new(3, ["First name can't be blank"])]
    end
  end

  describe '#report' do
    describe 'without a block' do
      it 'returns the inserted, failed and total number of rows' do
        import = UserImport.new("test/files/missing-first-name.xlsx").tap(&:run)
        assert_equal 2, import.report.inserted
        assert_equal 1, import.report.failed
        assert_equal 3, import.report.total
      end
    end

    describe 'with a block' do
      it 'returns the inserted, failed and total number of rows' do
        import = UserImport.new("test/files/missing-first-name.xlsx")
        import.run do |v|
          raise "failure!" if v[:first_name].nil?
          v
        end
        assert_equal 2, import.report.inserted
        assert_equal 1, import.report.failed
        assert_equal 3, import.report.total
      end
    end
  end
end
