if defined?(ActiveRecord::Base)
  module AttrEncryptor
    module Adapters
      module ActiveRecord
        def self.extended(base) # :nodoc:
          base.class_eval do
            attr_encrypted_options[:encode] = true
          end
        end

        protected

          # Ensures the attribute methods for db fields have been defined before calling the original 
          # <tt>attr_encrypted</tt> method
          def attr_encrypted(*attrs)
            define_attribute_methods rescue nil
            super
            attrs.reject { |attr| attr.is_a?(Hash) }.each { |attr| alias_method "#{attr}_before_type_cast", attr }

            self.encrypted_attributes.each do |attribute, options|
              if options[:index_key]
                self.define_singleton_method("find_by_#{attribute.to_s.downcase}") do |value|
                  self.where("#{options[:attribute]}_index".to_sym => self.generate_index_hash(options[:index_key], value)).first
                end
              end
            end
          end
      end
    end
  end

  ActiveRecord::Base.extend AttrEncryptor::Adapters::ActiveRecord
end
