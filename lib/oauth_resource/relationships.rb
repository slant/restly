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
      # Define Relationship
      define_method relationship do
        self.extend OauthResource::Relationships::Builder
        self.build(relationship, opts).find(send(:"#{relationship}_id"))
      end
    end

    def has_one_resource(relationship, opts={})
      # Define Relationship
      define_method relationship do
        self.extend OauthResource::Relationships::Builder
        self.build(relationship, opts).all.first
      end
    end

    def has_many_resources(relationship, opts={})
      # Define Relationship
      define_method relationship do
        self.extend OauthResource::Relationships::Builder
        if opts[:through]
          joiner = send(opts[:through])
          relationship = relationship.to_s.singularize.to_sym
          collection = joiner.collect(relationship)
          collection.extend OauthResource::Base::Collection
          collection.add_joiner(joiner, parent)
        else
          resource_klass = self.build(relationship, opts)
          collection = resource_klass.with_params("with_#{resource_name}_id".to_sym => id).all
          collection.extend OauthResource::Base::Collection
          collection.add_parent(parent)
        end
          collection
      end
    end

    def resource_name
      name.gsub(/.*::/,'').underscore
    end

  end

end