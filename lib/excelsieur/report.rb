# frozen_string_literal: true

module Excelsieur
  Report = Struct.new(:expected, :inserted, :failed) do
    def initialize(*args)
      super(*args)

      self.expected ||= 0
      self.inserted ||= 0
      self.failed ||= 0
    end

    def total
      inserted + failed
    end

    def done?
      expected == total
    end
  end
end
