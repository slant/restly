require "faraday_simulation"

# Sample Models
class Success
  def initialize(status=true)
    super({ success: status })
  end
end

class MemoryModel < Hash

  class_attribute :collection, :fields, instance_writer: false, instance_reader: false

  def self.find(id)
    all[id]
  end

  def self.all
    self.collection ||= []
  end

  def self.accepts_params
    self.new.except(:id, :created_at, :updated_at).keys
  end

  def self.spec
    { attributes: new.keys,
      actions: [
        {
          method: 'POST',
          parameters: accepts_params
        },
      ]
    }
  end

  def self.field(attr, options={})
    self.fields ||= {}
    options.assert_valid_keys(:default)
    self.fields[attr] = options[:default]
  end

  def initialize(hash={})
    (self.class.collection ||= []) << @instance = super(fields.merge(hash))
    binding.pry
    @instance[:id] = self.class.collection.index(@instance) + 1
  end

  def fields
    self.class.fields.reduce({}) { |fields, (field, value)| fields[field] = value.is_a?(Proc) ? value.call : value ; fields }
  end

  def []=(key, val)
    self[:updated_at] = Time.now unless key == :updated_at || !fields.keys.include?(:updated_at)
    super(key, val)
  end

end

class Post < MemoryModel

  field :body
  field :created_at, default: ->{ Time.now }
  # field :updated_at, default: ->{ Time.now }

end

success_message = { success: true }

class Requester

  def initialize(env, &block)
    @env = env
    @action = instance_eval(&block)
  end

  def response
    case format
      when "json"
        @action.to_json
      when "xml"
        @action.to_xml
      else
        @action.to_param
    end
  end

  private

  def format
    @env[:params]['format']
  end

  def model
    @env[:params]['model'].try(:classify).try(:constantize)
  end

  def data

  end

end

# Test Connection Object
connection = ->(builder){
  builder.use FaradaySimulation::Adapter do |stub|

    # Sample Objects
    stub.get '/:model.json' do
      [200, {}, model.to_json ]
    end

    stub.post '/:model.:format' do |env|
      req = Requester.new(env) { model.new(data) }
      [200, {}, req.response ]
    end
    #
    #stub.get '/:model/:id.json' do
    #  [200, {}, env[:params]['model'].classify.constantize.find(id: env[:params]['id']).to_json ]
    #end
    #
    #stub.put '/:model/:id.json' do
    #  [200, {}, env[:params]['model'].classify.constantize.find(id: env[:params]['id']).update(env[:params]['contact']).to_json ]
    #end
    #
    #stub.delete '/contacts/1.json' do
    #  [200, {}, Contact]
    #end
    #
    #stub.options("/contacts") do
    #  [200, {}, Contact.spec.to_json]
    #end
    #
    ## Associated Posts
    #stub.get '/contacts/1/posts.json' do
    #  [200, {}, Post.all.to_json]
    #end
    #
    #stub.post '/contacts/1/posts.json' do
    #  [200, {}, Post.new.sample_object.to_json]
    #end
    #
    #stub.get '/contacts/1/posts/1.json' do
    #  [200, {}, Post.new.sample_object.to_json]
    #end
    #
    #stub.put '/contacts/1/posts/1.json' do
    #  [200, {}, Post.new.to_json]
    #end
    #
    #stub.delete '/contacts/1/posts/1.json' do
    #  [200, {}, Post.new.to_json]
    #end
    #
    #stub.request(:options, "/contacts/1/posts.json") do
    #  [200, {}, Post.spec.to_json]
    #end
    #
    ## Standalone Posts
    ## Sample Objects
    #stub.get '/posts.json' do
    #  [200, {}, Post.all.to_json ]
    #end
    #
    #stub.post '/contacts.json' do
    #  [200, {}, Post.new(id: 1).to_json ]
    #end
    #
    #stub.get '/contacts/1.json' do
    #  [200, {}, Post.new(id: 1).to_json ]
    #end
    #
    #stub.put '/contacts/1.json' do
    #  [200, {}, Post.new(id: 1).to_json ]
    #end
    #
    #stub.delete '/contacts/1.json' do
    #  [200, {}, Post.success.to_json]
    #end
    #
    #stub.request(:options, "/contacts") do
    #  [200, {}, Post.spec.to_json]
    #end


  end
}

tc = Faraday::Connection.new &connection

binding.pry

Restly::Configuration.load_config(
  {
    site: 'http://fakesi.te',
    cache: false,
    use_oauth: true,
    connection_build: connection,
    outh_options: {
      client_id: 'default_id',
      client_secret: 'default_secret',
      default_format: 'json'
    },
  }
)