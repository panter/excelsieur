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

class ExcelsiorTest < Minitest::Test
  def setup
    User.delete_all
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
      { attribute: :first_name, header: "Vorname" },
      { attribute: :last_name, header: "Nachname" },
      { attribute: :email, header: "E-Mail" }
    ]
  end

  def test_import_run
    @import.run
    assert_equal User.all.size, 2
  end

  def test_import_run_with_block
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

  def test_validations
    import = UserImport.new("test/files/missing-column.xlsx")
    assert import.errors[:missing_column].any?
  end

  def test_model_validations
    import = UserImport.new("test/files/missing-first-name.xlsx").tap(&:run)
    assert import.errors[:model].any?
    assert_equal import.errors[:model], [Excelsior::Error.new(3, ["First name can't be blank"])]
  end

  def test_report
    import = UserImport.new("test/files/missing-first-name.xlsx").tap(&:run)
    assert_equal 2, import.report.inserted
    assert_equal 1, import.report.failed
    assert_equal 3, import.report.total
  end
end
