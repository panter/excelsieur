module Excelsior
  module Mapping
    def self.included(host_class)
      host_class.extend ClassMethods
    end

    module ClassMethods
      attr_reader :fields

      def map(header, options = {})
        @fields ||= []
        @fields << {
          attribute: options.fetch(:to),
          header: header
        }
      end
    end

    def map_row_values(row, columns)
      @fields.to_a.reduce({}) do |acc, field|
        idx = columns.index(field[:header])
        acc[field[:attribute]] = row[idx]
        acc
      end
    end
  end
end
