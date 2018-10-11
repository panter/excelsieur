# frozen_string_literal: true

require 'simple_xlsx_reader'
require 'rails'
require 'active_record'
require 'excelsieur/source'
require 'excelsieur/mapping'
require 'excelsieur/error'
require 'excelsieur/report'
require 'excelsieur/transaction'
require 'excelsieur/result'

module Excelsieur
  class Import
    include Source
    include Mapping
    include Transaction

    attr_accessor :source, :fields, :rows, :columns, :result
    delegate :errors, :report, to: :result

    def initialize(file = nil)
      self.source = file || self.class.source_file
      self.fields = self.class.fields

      @doc = ::SimpleXlsxReader.open(source)
      @sheet = @doc.sheets.first

      @columns = @sheet.rows.shift
      @rows = @sheet.rows

      @result = Result.new(@rows.length)
    end

    def run(&block)
      check_columns!

      return if result.failed?

      if self.class.use_transaction
        run_with_transaction(&block)
      else
        insert_rows(&block)
      end

      result
    end

    private

    def check_columns!
      fields.to_a.each do |f|
        errors[:missing_column] << { missing: f[:header] } unless @columns.include?(f[:header])
      end
    end

    def model_class
      self.class.name.gsub('Import', '').constantize
    end

    def run_with_transaction(&block)
      model_class.transaction do
        insert_rows(&block)

        raise ActiveRecord::Rollback if report.failed.positive?
      end
    end

    def add_model_errors(record, index)
      if record.errors.empty?
        report_insert
        return
      end

      report_failure

      errors[:model] << Error.new(index + 1, record.errors.full_messages)
    end

    def report_insert
      report.inserted += 1
    end

    def report_failure
      report.failed += 1
    end

    def insert_rows(&block)
      @rows.map.with_index do |row, i|
        attributes = map_row_values(row, @columns)
        insert_row(attributes, i, &block)
      end
    end

    def insert_row(attributes, index, &block)
      if block_given?
        insert_row_with_block(attributes, &block)
      else
        insert_row_without_block(attributes, index)
      end
    end

    def insert_row_with_block(attributes)
      result = yield(attributes)
      report_insert
      result
    rescue StandardError
      report_failure
    end

    def insert_row_without_block(attributes, index)
      record = model_class.create(attributes)
      add_model_errors(record, index)
    end
  end
end
