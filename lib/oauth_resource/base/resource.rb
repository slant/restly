module OauthResource
  class Base
    module Resource
      extend ActiveSupport::Concern
      extend ActiveSupport::Autoload

      autoload :ClassMethods

      included do

        rattr_accessor :site, :path, :resource_name, :client_id, :client_secret, :api_format, :include_root_in_json
        attr_accessor :params

        self.api_format = OauthResource::Configuration.default_format
        self.site = OauthResource::Configuration.site
        self.client_id = OauthResource::Configuration.client_id
        self.client_secret = OauthResource::Configuration.client_secret

      end

        #############################################
        ## Load and Authorize the Resource Instance
        #############################################

        def initialize(token_object=nil, opts={})
          self.extend OauthResource::Base::ObjectMethods
          self.connection = token_object || OAuth2::AccessToken.new(self.class.client, nil)
          self.resource_name = opts[:resource_name] || self.class.resource_name
          self.params = {}
          @path = opts[:path] || self.class.path
          connection.cache_opts = cache_opts if self.respond_to?(:cache_opts)
        end

        #############################################
        ## Resource Methods
        #############################################

        def path(*args)
          full_path = ([@path] + args).join('/')
          [full_path, self.class.api_format].compact.join('.')
        end

        def with_params!(hash={})
          self.params.merge!(hash)
          self
        end

        private

        #############################################
        ## Build the Response
        #############################################

        # Build an instance object from response objects
        def instance_for_response(response, opts={})
          opts.reverse_merge!({ parsed: true, error: true })
          #return OauthResource::Base::Error::Instance.new( self, response.parsed ) if response.error && opts[:error]
          response = response.parsed if opts[:parsed]
          response = response.fetch(resource_name, {}) if response[resource_name]
          "#{self.class}::Instance".constantize.new self, response
        end

        def collection_for_response(response, opts={})
          opts.reverse_merge!({ parsed: true, error: true })
          response = response.parsed if opts[:parsed]
          response = response.fetch(resource_name.to_s.pluralize, {}) if response[resource_name.to_s.pluralize]
          response = response.collect do |i|
            instance_for_response( i, parsed: false )
          end
          "#{self.class}::Collection".constantize.new self, response, opts[:pagination]
        end

    end
  end
end