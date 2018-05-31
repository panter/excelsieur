require "test_helper"
require "excelsior/import"

class UserImport < Excelsior::Import
  source "test/files/complete.xlsx"

  map "Vorname", to: :firstname
  map "Nachname", to: :lastname
  map "E-Mail", to: :email
end

class User
  class << self
    def create!(attributes)
      @all ||= []
      @all << attributes
    end

    def all
      @all ||= []
    end
  end
end

class ExcelsiorTest < Minitest::Test
  def setup
    @import = UserImport.new
  end

  def test_that_it_has_a_version_number
    refute_nil ::Excelsior::VERSION
  end

  def test_class_level_source
    import = UserImport.new
    assert_equal "test/files/complete.xlsx", import.source
  end

  def test_instance_level_source
    import = UserImport.new("test/files/missing-column.xlsx")
    assert_equal "test/files/missing-column.xlsx", import.source
  end

  def test_import_rows
    assert_equal 2, @import.rows.length
  end

  def test_import_columns
    assert_equal 3, @import.columns.length
    assert_equal "E-Mail", @import.columns[0]
    assert_equal "Vorname", @import.columns[1]
    assert_equal "Nachname", @import.columns[2]
  end

  def test_mapping
    assert_equal @import.fields, [
      {attribute: :firstname, header: "Vorname"},
      {attribute: :lastname, header: "Nachname"},
      {attribute: :email, header: "E-Mail"}
    ]
  end

  def test_import_run
    results = @import.run
    assert_equal User.all.size, 2
  end

  def test_import_run_with_block
    results = @import.run { |v| v }
    assert_equal results[0], {
      firstname: "Hans",
      lastname: "Müller",
      email: "hans@mueller.com"
    }
    assert_equal results[1], {
      firstname: "Jögi",
      lastname: "Brunz",
      email: "jb@runz.com"
    }
  end

  def test_validations
    import = UserImport.new("test/files/missing-column.xlsx")
    assert import.errors[:missing_column].any?
  end
end
