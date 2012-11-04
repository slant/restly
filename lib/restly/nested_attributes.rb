module Restly::NestedAttributes

  extend ActiveSupport::Concern

  included do
    class_attribute :resource_nested_attributes_options, :instance_writer => false
    self.resource_nested_attributes_options = {}

    inherited do
      self.resource_nested_attributes_options = resource_nested_attributes_options.dup
    end

  end

  private

  # One To One Association
  def assign_nested_attributes_for_one_to_one_resource_association(association_name, attributes, assignment_opts = {})
    options = self.nested_attributes_options[association_name]
    association_attributes[association_name] = attributes.delete("#{association_name}_attributes") || {}
    associated_instance = send(association_name) ||
      self.class.reflect_on_resource_association(association_name).build(self)
    associated_instance.attributes = association_attributes
  end

  # Collection Association
  def assign_nested_attributes_for_collection_resource_association(association_name, attributes_collection, assignment_opts = {})

    unless attributes_collection.is_a?(Hash) || attributes_collection.is_a?(Array)
      raise ArgumentError, "Hash or Array expected, got #{attributes_collection.class.name} (#{attributes_collection.inspect})"
    end

    if attributes_collection.is_a? Hash
      keys = attributes_collection.keys
      attributes_collection = if keys.include?('id') || keys.include?(:id)
                                Array.wrap(attributes_collection)
                              else
                                attributes_collection.values
                              end
    end

    association = self.class.reflect_on_resource_association(association_name)
    existing_records = send(association_name)

    attributes_collection.each do |attributes|
      attributes = attributes.with_indifferent_access
      if attributes[:id].blank?
        send(association_name) << association.build(self, attributes.except(:id))
      elsif existing_record = existing_records.find{ |record| record.id.to_s == attributes['id'].to_s }
        existing_record.attributes = attributes
      end
    end

  end

  def set_nested_attributes_for_save
    @attributes = @attributes.inject(HashWithIndifferentAccess.new) do |hash, (k, v)|
      k = [resource_nested_attributes_options[k.to_sym][:write_prefix], k, resource_nested_attributes_options[k.to_sym][:write_suffix]].compact.join('_') if resource_nested_attributes_options[k.to_sym].present?
      hash[k] = v
      hash
    end
  end

  module ClassMethods
    REJECT_ALL_BLANK_PROC = proc { |attributes| attributes.all? { |key, value| key == '_destroy' || value.blank? } }

    def accepts_nested_attributes_for_resource(*attr_names)
      options = { :allow_destroy => false, :update_only => false, :write_prefix => nil, :write_suffix => 'attributes' }
      options.update(attr_names.extract_options!)
      options.assert_valid_keys(:allow_destroy, :reject_if, :limit, :update_only, :write_prefix, :write_suffix)
      options[:reject_if] = REJECT_ALL_BLANK_PROC if options[:reject_if] == :all_blank

      before_save :set_nested_attributes_for_save

      attr_names.each do |association_name|
        if reflection = reflect_on_resource_association(association_name)
          reflection.options[:autosave] = true

          resource_nested_attributes_options = self.resource_nested_attributes_options.dup
          resource_nested_attributes_options[association_name.to_sym] = options
          self.resource_nested_attributes_options = resource_nested_attributes_options

          type = (reflection.collection? ? :collection : :one_to_one)

          if method_defined?("#{association_name}_attributes=")
              remove_method("#{association_name}_attributes=")
          end

          define_method "#{association_name}_attributes=" do |attributes|
            send("assign_nested_attributes_for_#{type}_resource_association", association_name.to_sym, attributes, mass_assignment_options)
          end

        else
          raise ArgumentError, "No association found for name `#{association_name}'. Has it been defined yet?"
        end
      end
    end
  end

end