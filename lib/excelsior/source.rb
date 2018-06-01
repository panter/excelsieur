# frozen_string_literal: true

module Excelsior
  module Source
    def self.included(host_class)
      host_class.extend ClassMethods
    end

    module ClassMethods
      attr_accessor :source_file

      def source(file)
        self.source_file = file
      end
    end
  end
end
