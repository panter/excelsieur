require 'simple_xlsx_reader'
require 'rails'
require 'active_record'
require 'excelsior/source'
require 'excelsior/mapping'
require 'excelsior/error'

module Excelsior
  class Import
    include Source
    include Mapping

    attr_accessor :source, :fields, :errors
    attr_accessor :rows, :columns

    def initialize(file = nil)
      self.source = file || self.class.source_file
      self.fields = self.class.fields

      @doc = ::SimpleXlsxReader.open(self.source)
      @sheet = @doc.sheets.first

      @columns = @sheet.rows.shift
      @rows = @sheet.rows

      valid?
    end

    def run # takes an optional block
      @rows.map.with_index do |row, i|
        attributes = map_row_values(row, @columns)
        if block_given?
          yield attributes
        else
          record = model_class.create(attributes)
          add_model_errors(record, i)
        end
      end
    end

    def valid?
      @errors = fields.to_a.reduce({}) do |acc, f|
        acc[:missing_column] ||= []

        unless @columns.include?(f[:header])
          acc[:missing_column] << { missing: f[:header] }
        end
        acc
      end
    end

    private

    def model_class
      self.class.name.gsub("Import", "").constantize
    end

    def add_model_errors(record, index)
      return if record.errors.empty?

      @errors[:model] ||= []

      @errors[:model] << Error.new(index + 1, record.errors.full_messages)
    end
  end
end
