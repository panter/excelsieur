# frozen_string_literal: true

module Excelsior
  class Result
    module Statuses
      PENDING = :pending
      SUCCEEDED = :succeeded
      FAILED = :failed
    end

    attr_accessor :errors, :report

    def initialize(total_rows)
      self.errors = {
        missing_column: [],
        model: []
      }
      self.report = Report.new(total_rows)
    end

    def status
      return Statuses::FAILED if errors[:missing_column].any? || errors[:model].any?

      if report.done?
        Statuses::SUCCEEDED
      else
        Statuses::PENDING
      end
    end

    def failed?
      status == Result::Statuses::FAILED
    end
  end
end
