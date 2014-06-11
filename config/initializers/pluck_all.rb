module ActiveRecordExtension
  extend ActiveSupport::Concern

  module ClassMethods
    def pluck_all(*args)
      args.map! do |column_name|
        if column_name.is_a?(Symbol) && column_names.include?(column_name.to_s)
          "#{connection.quote_table_name(table_name)}.#{connection.quote_column_name(column_name)}"
        else
          column_name.to_s
        end
      end

      self.connection.select_all(self.select(args).arel).map! do |attributes|
        initialized_attributes = self.initialize_attributes(attributes)
        attributes.map do |key, attribute|
          self.type_cast_attribute(key, initialized_attributes)
        end
      end
    end
  end
end

# include the extension
ActiveRecord::Base.send(:include, ActiveRecordExtension)