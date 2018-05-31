require 'simple_xlsx_reader'
require 'rails'
require 'active_record'
require 'excelsior/source'
require 'excelsior/mapping'

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
      @rows.map do |row|
        attributes = map_row_values(row, @columns)
        if block_given?
          yield attributes
        else
          model_class.create!(attributes)
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
  end
end
