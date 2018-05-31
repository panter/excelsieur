module Excelsior
  Report = Struct.new(:inserted, :failed) do
    def initialize(*args)
      super(*args)

      self.inserted ||= 0
      self.failed ||= 0
    end

    def total
      inserted + failed
    end
  end
end
