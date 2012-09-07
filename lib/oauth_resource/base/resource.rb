module OauthResource
  class Base
    module Resource
      extend ActiveSupport::Concern
      extend ActiveSupport::Autoload

      autoload :ClassMethods

      included do

        rattr_accessor :site, :path, :resource_name, :client_id, :client_secret, :format, :instance_json_root, :collection_json_root
        attr_accessor :params

        self.format = OauthResource::Configuration.default_format
        self.site = OauthResource::Configuration.site
        self.client_id = OauthResource::Configuration.client_id
        self.client_secret = OauthResource::Configuration.client_secret
        self.instance_json_root = true
        self.collection_json_root = true

      end

        #############################################
        ## Load and Authorize the Resource Instance
        #############################################

        def initialize(token_object=nil, opts={})
          self.extend OauthResource::Base::ObjectMethods
          self.connection = token_object || OAuth2::AccessToken.new(self.class.client, nil)
          self.resource_name = opts[:resource_name] || self.class.resource_name
          @path = opts[:path] || self.class.path
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
          instance_for_response connection.get( path(id), params: params)
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
          if spec
            spec.attributes.each do |k|
              self.send("#{k}=", nil)
            end
          else
            instance_for_response({}, parsed: false, error: false)
          end
        end

        def error
          connection.error
        end

        def path(*args)
          full_path = ([@path] + args).join('/')
          [full_path, self.class.format].compact.join('.')
        end

        def add_params(hash)
          self.params ||= {}
          self.params.merge!(hash)
        end

        private

        #############################################
        ## Build the Response
        #############################################

        # Build an instance object from response objects
        def instance_for_response(response, opts={})
          opts.reverse_merge!({ parsed: true, error: true , json_root: self.class.instance_json_root })
          return OauthResource::Base::Error::Instance.new( self, response.parsed ) if error && opts[:error]
          response = response.parsed if opts[:parsed]
          response = response.fetch(resource_name, {}) if opts[:json_root]
          "#{self.class}::Instance".constantize.new self, response
        end

        def collection_for_response(response, opts={})
          opts.reverse_merge!({ parsed: true, error: true , json_root: self.class.collection_json_root })
          response = response.parsed if opts[:parsed]
          response = response.fetch(resource_name.to_s.pluralize, {}) if opts[:json_root]
          response = response.collect do |i|
            instance_for_response( i, parsed: false, json_root: true )
          end
          "#{self.class}::Collection".constantize.new self, response
        end

    end
  end
end