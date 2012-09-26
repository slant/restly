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

      define_method relationship do |options|
        self.extend OauthResource::Relationships::Builder
        combined_opts = opts.merge(options)

        relationship_klass = self.build(relationship, combined_opts)
        relationship_klass.find(send(:"#{relationship}_id"))
      end

    end

    def has_one_resource(relationship, opts={})

      define_method relationship do |options|
        self.extend OauthResource::Relationships::Builder
        combined_opts = opts.merge(options)

        relationship_klass = self.build(relationship, combined_opts)
        relationship_klass.all.first
      end

    end

    def has_many_resources(relationship, opts={})

      define_method relationship do |options|
        self.extend OauthResource::Relationships::Builder
        combined_opts = opts.merge(options)
        parent = self
        joiner = nil
        relationship_klass = self.build(relationship, combined_opts)

        objects_array = if opts[:through]
          joiner = send(opts[:through])
          relationship = relationship.to_s.singularize.to_sym
          joiner.collect { |i| i.relationship(options) }

        else
          relationship_klass_scoped = relationship_klass.with_params("with_#{resource_name}_id".to_sym => id)
          relationship_klass_scoped.all

        end

        collection = OauthResource::Base::Collection.new relationship_klass, objects_array
        OauthResource::Proxies::Association.new(collection, parent, joiner)

      end
    end

    def resource_name
      name.gsub(/.*::/,'').underscore
    end

  end

end