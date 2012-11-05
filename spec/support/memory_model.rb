class MemoryModel < Hash

  cattr_accessor :models

  self.models = []

  class RecordNotFound < StandardError
  end

  class_attribute :collection, :fields, instance_writer: false, instance_reader: false

  class << self

    delegate :first, :last, :[], to: :collection

    def inherited(subclass)
      subclass.fields = {}
      subclass.collection = []
      subclass.send :field, :id
      self.models << subclass
    end

    def all
      collection
    end

    def truncate_all_models
      models.each { |model| model.truncate }
    end

    def truncate
      self.collection.clear
    end

    alias_method :delete_all, :truncate

    def find(id)
      instance = all[id - 1]
      raise RecordNotFound, "Record was not found" unless instance
      instance
    end

    def accepts_params
      self.new.except(:id, :created_at, :updated_at).keys
    end

    def spec
      { attributes: new.keys,
        actions: [
          {
            method: 'POST',
            parameters: accepts_params
          },
        ]
      }
    end

    def field(attr, options={})
      options.assert_valid_keys(:default)
      self.fields[attr] = options[:default]
    end

  end

  def initialize(hash={})
    super
    self.class.collection << @instance = merge!(fields.merge hash)
    @instance[:id] = self.class.collection.index(@instance) + 1
  end

  def update(hash={})
    self[:updated_at] = Time.now if fields.keys.include?(:updated_at)
    merge!(hash).slice *fields.keys
  end

  def delete
    self.class.collection.delete(self)
    freeze
    true
  end

  def merge(hash)
    hash.assert_valid_keys(*self.class.fields.keys)
    super
  end

  def merge!(hash)
    hash.assert_valid_keys(*self.class.fields.keys)
    super
  end

  def []=(key, value)
    valid = {}
    valid[key] = value
    valid.assert_valid_keys(*self.class.fields.keys)
    super(key, value)
  end

  private

  def fields
    self.class.fields.reduce({}) { |fields, (field, value)| fields[field] = value.is_a?(Proc) ? value.call : value ; fields }
  end

end