module OauthResource::Relationships
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload

  autoload :Builder

  included do ; end

  def resource_name
    self.class.resource_name
  end

  module ClassMethods

    def belongs_to_resource(relationship, opts={})
      instance_class.send :define_method, relationship do
        self.extend OauthResource::Relationships::Builder
        self.build(relationship, opts).find(send(:"#{relationship}_id"))
      end
    end

    def has_one_resource(relationship, opts={})
      # Define Relationship
      instance_class.send :define_method, relationship do
        self.extend OauthResource::Relationships::Builder
        opts[:path] ||= rel_path(id, relationship)
        self.build(relationship, opts).all.first
      end
    end

    def has_many_resources(relationship, opts={})
      # Define Relationship
      instance_class.send :define_method, relationship do
        self.extend OauthResource::Relationships::Builder
        if opts[:through]
          joiner = send(opts[:through])
          relationship = relationship.to_s.singularize.to_sym
          resource_klass = self.build(relationship, opts)
          OauthResource::Base::Collection.with_joiner(resource_klass, self, joiner)
        else
          resource_klass = self.build(relationship, opts)
          OauthResource::Base::Collection.with_parent(resource_klass, self)
          opts[:path] ||= rel_path(id, relationship)
          resource_klass = self.build(relationship, opts).with_params!("with_#{resource_name}_id".to_sym => id)
          resource_klass.all.select{ |i| i.send(:"#{resource_name}_id") == id }
        end
      end
    end

    def resource_name
      name.gsub(/.*::/,'').underscore
    end

    private

    def instance_class
      if self.const_defined?("Instance") && "#{name}::Instance".constantize.superclass == OauthResource::Base::Instance
        "#{name}::Instance".constantize
      else
        self
      end
    end

  end

end