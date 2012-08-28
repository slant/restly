module OauthResource
  class Base
    module Resource
      extend ActiveSupport::Concern
      extend ActiveSupport::Autoload

      autoload :ClassMethods

      included do

        attr_accessor :params
        cache (OauthResource::Configuration.cache_opts || {}) if OauthResource::Configuration.cache

      end

        #############################################
        ## Load and Authorize the Resource Instance
        #############################################

        def initialize(token_object=nil, opts={})
          self.extend OauthResource::Base::ObjectMethods
          self.connection = token_object || OAuth2::AccessToken.new(self.class.client, nil)
          self.resource_name = opts[:resource_name] || self.class.resource_name
          self.path = opts[:path] || self.class.path
          connection.cache_opts = cache_opts if self.respond_to?(:cache_opts)
        end

        #############################################
        ## Resource Methods
        #############################################

        # GET /:path
        # Fetches the index of the remote resource
        def all
          collection_for_response connection.get(path, params: params)
        end

        # GET /:path/:id
        # Fetches A Remote Resource
        def find(id)
          instance_for_response connection.get( [path, id].join('/'), params: params)
        end

        # POST /:path
        # Creates a Remote Resource
        def create(attrs={})
          connection.post(path, body: attrs)
        end

        # OPTIONS /:path
        # Fetches the spec of a remote resource
        def spec
          connection.request(:options, path).parsed.extend OauthResource::Base::ObjectMethods
        end

        # Initializes a resource locally when the spec is known.
        def new
          spec.attributes.each do |k|
            self.send("#{k}=", nil)
          end
        end

        private

        #############################################
        ## Build the Response
        #############################################

        # Build an instance object from response objects
        def instance_for_response(response, opts={})
          opts = { parsed: true }.merge(opts)
          response = response.parsed.fetch(resource_name, {}) if opts[:parsed]
          "#{self.class}::Instance".constantize.new self, response
        end

        def collection_for_response(response, opts={})
          response = response.parsed
          response[resource_name.to_s.pluralize] = response.fetch(resource_name.to_s.pluralize,[]).collect do |i|
            instance_for_response( i, parsed: false )
          end
          "#{self.class}::Collection".constantize.new self, response
        end

    end
  end
end