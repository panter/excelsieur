# frozen_string_literal: true

module Excelsior
  module Transaction
    def self.included(host_class)
      host_class.extend ClassMethods
    end

    module ClassMethods
      attr_accessor :use_transaction

      def transaction(use_transaction)
        self.use_transaction = use_transaction
      end
    end
  end
end
