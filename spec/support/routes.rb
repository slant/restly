require "faraday_simulation"
require "faraday_middleware"
require "support/requester"

# Test Connection Object
connection = ->(builder){
  builder.use Faraday::Request::UrlEncoded

  builder.response :xml,  :content_type => /\bxml$/
  builder.response :json, :content_type => /\bjson$/

  builder.use FaradaySimulation::Adapter do |stub|

    # Associated
    stub.get '/:model.:format' do |env|
      req = Requester.new(env) { model.all }
      [200, req.response_headers, req.response ]
    end

    stub.post '/:model.:format' do |env|
      req = Requester.new(env) { model.new(data) }
      [200, req.response_headers, req.response ]
    end

    stub.get '/:model/:id.:format' do |env|
      req = Requester.new(env) { model.find(params[:id]) }
      [200, req.response_headers, req.response ]
    end

    stub.put '/:model/:id.:format' do |env|
      req = Requester.new(env) { model.find(params[:id]).update(data) }
      [200, req.response_headers, req.response ]
    end

    stub.delete '/:model/:id.:format' do |env|
      req = Requester.new(env) { model.find(params[:id]).delete }
      [200, req.response_headers, req.response ]
    end

    stub.options '/:model/:id' do |env|
      env[:params]["format"] = "json"
      req = Requester.new(env) { model.spec }
      [200, req.response_headers, req.response ]
    end

    # Associated
    stub.get '/:parent_model/:parent_id/:model.:format' do |env|
      req = Requester.new(env) { model.all }
      [200, req.response_headers, req.response ]
    end

    stub.post '/:parent_model/:parent_id/:model.:format' do |env|
      req = Requester.new(env) { model.new(data) }
      [200, req.response_headers, req.response ]
    end

    stub.get '/:parent_model:model/:parent_id/:id.:format' do |env|
      req = Requester.new(env) { model.find(params[:id]) }
      [200, req.response_headers, req.response ]
    end

    stub.put '/:parent_model/:parent_id:model/:id.:format' do |env|
      req = Requester.new(env) { model.find(params[:id]).update(data) }
      [200, req.response_headers, req.response ]
    end

    stub.delete '/:parent_model/:parent_id/:model/:id.:format' do |env|
      req = Requester.new(env) { model.find(params[:id]).delete }
      [200, req.response_headers, req.response ]
    end

    stub.options '/:parent_model/:parent_id/:model/:id' do |env|
      env[:params]["format"] = "json"
      req = Requester.new(env) { model.spec }
      [200, req.response_headers, req.response ]
    end

  end
}

Restly::Configuration.load_config(
  {
    site: 'http://fakesi.te',
    cache: false,
    use_oauth: true,
    client_options: {
      connection_build: connection
    },
    oauth_options: {
      client_id: 'default_id',
      client_secret: 'default_secret',
      default_format: 'json'
    },
  }
)