class Restly::Associations::Base
  extend ActiveSupport::Autoload

  autoload :Loaders
  autoload :Stubs
  autoload :Builders
  autoload :Modifiers
  autoload :Conditionals

  include Loaders
  include Stubs
  include Builders
  include Modifiers
  include Conditionals

  attr_reader :name, :namespace, :polymorphic, :options

  def initialize(owner, name, options={})
    @name = name
    @namespace = options.delete(:namespace) || owner.name.gsub(/(::)?\w+$/, '')
    @polymorphic = options.delete(:polymorphic)
    options[:class_name] ||= name.to_s.classify
    @owner = owner
    @options = options
  end

  def association_class
    [@namespace, options[:class_name]].select(&:present?).join('::').constantize
  end

  private

  def association_resource_name
    collection? ? association_class.resource_name.pluralize : association_class.resource_name
  end

end