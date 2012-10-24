class Restly::Associations::Base

  attr_reader :name, :association_class, :namespace, :polymorphic, :options

  def initialize(owner, name, options={})
    @name = name
    @namespace = options.delete(:namespace) || owner.name.gsub(/::\w+$/, '')
    @polymorphic = options.delete(:polymorphic)
    options[:class_name] ||= name.to_s.classify
    @owner = owner
    @association_class = [@namespace, options.delete(:class_name)].compact.join('::').constantize
    @options = options
  end

  def collection?
    false
  end

  def build(*args)
    new_instance = @association_class.new(*args)
    new_instance.write_attribute("#{@owner.resource_name}_id") if @association_class.respond_to?("#{@owner.resource_name}_id") && !self.class.send(:reflect_on_resource_association, :custom_pages).embedded?
    new_instance
  end

  private

  def authorize(klass, authorization = nil)
    if (!klass.authorized? && @owner.respond_to?(:authorized?) && @owner.authorized?) || authorization
      klass.authorize(authorization || @owner.connection)
    else
      klass
    end
  end

end