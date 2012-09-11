class OauthResource::Base::Collection < Array
  include ActiveModel::Serialization
  extend ActiveSupport::Autoload

  autoload :WithJoiner
  autoload :WithParent

  delegate :find, :create, :new, :build, to: :resource

  def initialize( resource, response, opts={} )
    self.extend OauthResource::Base::ObjectMethods
    super(response || [])

    self.resource   = resource
    self.pagination = nil
    self.parent     = opts[:parent]

    if self.resource.paginates?
      self.paginate(resource.pagination_opts)
    end

  end

  def paginate(opts={})
    self.pagination = opts.reverse_merge({
      per_page: 25,
        objects: {
          base:         nil,
          per_page:     :per_page,
          current_page: :current_page,
          total_pages:  :total_pages,
          total_pages:  :total_entries,
      }
    })
    self.extend OauthResource::Base::Collection::Paginated
  end

  def self.with_parent(resource, parent, opts={})
    collection = resource.with_params!("with_#{parent.resource_name}_id".to_sym => id).all
    collection.extend OauthResource::Base::Collection::WithParent
    collection.parent     = parent
    collection.parent_as  = opts[:as]
    collection.select{ |i| i.send(:"#{parent.resource_name}_id") == parent.id }
  end

  def self.with_joiner(resource, parent, joiner, opts={})
    collection = self.new resource, joiner.collect(&resource.resource_name.to_sym)
    collection.extend OauthResource::Base::Collection::WithJoiner
    collection.parent       = parent
    collection.joiner       = joiner.model_name.constantize
    collection.parent_as    = opts[:as]
    collection
  end



end
