class MemoryModel < Hash

  cattr_accessor :models

  self.models = []

  class RecordNotFound < StandardError
  end

  class_attribute :collection, :fields, instance_writer: false, instance_reader: false

  class << self

    delegate *(Array.instance_methods - Object.instance_methods), to: :collection

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

    private

    def field(attr, options={})
      options.assert_valid_keys(:default)
      self.fields[attr] = options[:default]
    end

    def belongs_to(association, options={})
      options.assert_valid_keys(:class_name)
      foreign_key = options[:foreign_key] || "#{association}_id".to_sym
      field foreign_key
      klass = -> { (options[:class_name] || association).classify.constantize }
      define_method association do

        extender = Module.new do

          def build
            klass.new(foreign_key.to_sym => self[:id])
          end

          def =(obj)
            raise "invalid" unless obj.is_a(klass)
            obj.update(foreign_key.to_sym => self[:id])
          end

        end

        instance = klass.call.find(self[foreign_key])
        instance.extend extender

      end
    end

    def has_one(association, options={})
      options.assert_valid_keys(:class_name, :foreign_key)
      foreign_key = options[:foreign_key] || "#{name}_id".to_sym
      klass = -> { (options[:class_name] || association).classify.constantize }
      define_method association do

        extender = Module.new do

          def build
            klass.new(foreign_key.to_sym => self[:id])
          end

          def =(obj)
            raise "invalid" unless obj.is_a(klass)
            obj.update(foreign_key.to_sym => self[:id])
          end

        end

        instance = klass.call.all.find {|i| i[foreign_key] == self[:id] }
        instance.extend extender

      end
    end

    def has_many(association, options={})
      options.assert_valid_keys(:class_name, :foreign_key)
      foreign_key = options[:foreign_key] || "#{name}_id".to_sym
      klass = -> { (options[:class_name] || association).classify.constantize }
      define_method association do

        extender = Module.new do

          def build
            klass.new(foreign_key.to_sym => self[:id])
          end

          def <<(obj)
            raise "invalid!" unless obj.is_a(klass)
            obj.update(foreign_key.to_sym => self[:id])
          end

        end

        collection = klass.call.all.select {|i| i[foreign_key] == self[:id] }
        collection.extend extender

      end
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