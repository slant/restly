require "faraday_simulation"

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