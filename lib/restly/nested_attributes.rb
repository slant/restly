module Restly::NestedAttributes

  ATTR_MATCHER = /(?<attr>\w+)_attributes=$/

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
  def assign_nested_attributes_for_one_to_one_resource_association( association_name, attributes )

    association_attributes[association_name] = attributes.delete("#{association_name}_attributes") || {}
    associated_instance = send(association_name) ||
      self.class.reflect_on_resource_association(association_name).build(self)
    associated_instance.attributes = association_attributes

  end

  # Collection Association
  def assign_nested_attributes_for_collection_resource_association(association_name, attributes_collection)

    unless attributes_collection.is_a?(Hash) || attributes_collection.is_a?(Array)
      raise ArgumentError,
            "Hash or Array expected, got #{attributes_collection.class.name} (#{attributes_collection.inspect})"
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
      elsif (existing_record = existing_records.find{ |record| record.id.to_s == attributes['id'].to_s })
        existing_record.attributes = attributes
      end
    end

  end

  def set_nested_attributes_for_save
    @attributes = @attributes.reduce(HashWithIndifferentAccess.new) do |hash, (key, v)|
      options = resource_nested_attributes_options[key.to_sym]
      key = [ options[:write_prefix], key, options[:write_suffix] ].compact.join('_') if options.present?
      hash[key] = v
      hash
    end
  end

  def nested_attribute_missing(m, *args)
    if !!(matched = ATTR_MATCHER.match m) && (options = resource_nested_attributes_options[(attr = matched[:attr])])
      send( "assign_nested_attributes_for_#{options[:association_type]}_resource_association", attr, *args )
    else
      raise Restly::Error::InvalidNestedAttribute, "Nested Attribute does not exist!"
    end
  end

  def method_missing(m, *args, &block)
    nested_attribute_missing(m, *args)
  rescue Restly::Error::InvalidNestedAttribute
    super
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

        if ( reflection = reflect_on_resource_association(association_name) )
          reflection.options[:autosave] = true
          options[:association_type] = (reflection.collection? ? :collection : :one_to_one)
          self.resource_nested_attributes_options[association_name.to_sym] = options

        else
          raise ArgumentError, "No association found for name `#{association_name}'. Has it been defined yet?"
        end
      end
    end
  end

end