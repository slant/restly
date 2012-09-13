module OauthResource::Base::InstanceActions

  include OauthResource::Base::GenericMethods

  def initialize(attributes = nil, options = {})
    @init_options = options
    @attributes = {}
    @association_cache = {}
    @aggregation_cache = {}
    @attributes_cache = {}
    @new_record = options[:loaded] ? false : true
    @readonly = options[:readonly] || false
    @previously_changed = {}
    @changed_attributes = {}
    @response = nil
    @relation = options[:relation]
    self.attributes = attributes || {}
    self.path = [path, id].join('/')
    self.path = nil unless exists?
  end

  def save
    @previously_changed = changes
    @changed_attributes.clear
    update_or_create
  end

  def delete
    connection.delete(path_with_format)
    false
    freeze
  end

  def update_or_create
    if new_record?
      @attributes = self.class.create(attributes).attributes
    else
      connection.put(path_with_format, body: attributes)
    end
    self
  end

  def update_attributes(attributes)
    self.attributes = attributes
    save
  end

  def attributes=(attributes)
    attributes.each do |k,v|
      send("#{k}=".to_sym, v)
    end
  end

  def attributes
    @attributes
  end

  def persisted?
    !new_record?
  end

  def new_record?
    id && !exists?
  end

  def exists?
    reload!
    @response.status == 200
  end

  def reload!
    connection.get
  end

  def method_missing(m, args, &block)
    if !!(/(?<attr>\w+)=$/ =~ m.to_s) && (attr = attr.to_sym) && permitted_attributes.include?(attr) && args.size == 1
      send("#{attr}_will_change!".to_sym) unless value == @attributes[attr]
      @attributes[attr] = args.first

    elsif !!(/(?<attr>\w+)=?$/ =~ m.to_s) && (attr = attr.to_sym) && permitted_attributes.include?(attr)
      @attributes[attr]
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    !!(/(?<attr>\w+)=?$/ =~ m.to_s) && (attr = attr.to_sym) && permitted_attributes.include?(attr)
  end

  def init_options
    @init_options
  end

end