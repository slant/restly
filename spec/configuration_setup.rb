# Sample Objects
class SampleClass < Hash

  def self.all
    1..10.map { |index| new(id: index) }
  end

  def self.success(status=true)
    { success: status }
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

  def initialize(hash={})
    super SAMPLE.merge(id: nil).merge(hash)
  end

end


class Contact < SampleClass

  SAMPLE = {
    first_name:   "John",
    middle_name:  "Michael",
    last_name:    "Doe",
    age:          30,
    created_at:   10.days.ago.to_time,
    updated_at:   1.day.ago.to_time,
    height:       62.5
  }

end

class Comment

  SAMPLE = {
    post_id:      1,
    content:      "Hello John",
    created_at:   10.days.ago.to_time,
    updated_at:   1.day.ago.to_time
  }

  def self.embedded
    1..5.map { new.slice(:id, :content) }
  end

end

class Post < SampleClass

  SAMPLE = {
    contact_id:   1,
    body:         "Hello World",
    created_at:   2.days.ago.to_time,
    updated_at:   5.hours.ago,
    updated_by:   Contact.new(first_name: "Jane", middle_name: "Lindsey", last_name: "Smith"),
    comments:     Comment.embedded
  }

  def self.associated
    1..5.map { new.slice(:id, :body) }
  end

end

success_message = { success: true }

# Test Connection Object
connection = ->{
  use Faraday::Adapter::Test do |stub|

    # Sample Objects
    stub.get '/contacts.json' do
      [200, {}, Contact.all.to_json ]
    end

    stub.post '/contacts.json' do
      [200, {}, Contact.new(id: 1).to_json ]
    end

    stub.get '/contacts/1.json' do
      [200, {}, Contact.new(id: 1).to_json ]
    end

    stub.put '/contacts/1.json' do
      [200, {}, Contact.new(id: 1).to_json ]
    end

    stub.delete '/contacts/1.json' do
      [200, {}, success_message.to_json]
    end

    stub.request(:options, "/contacts") do
      [200, {}, Contact.spec.to_json]
    end

    # Associated Objects
    stub.get '/contacts/1/posts.json' do
      [200, {}, sample_collection.to_json]
    end

    stub.post '/contacts/1/posts.json' do
      [200, {}, sample_object.to_json]
    end

    stub.get '/contacts/1/posts/1.json' do
      [200, {}, sample_object.to_json]
    end

    stub.put '/contacts/1/posts/1.json' do
      [200, {}, sample_object.to_json]
    end

    stub.delete '/contacts/1/posts/1.json' do
      [200, {}, success_message.to_json]
    end

    stub.request(:options, "/contacts") do
      [200, {}, Contact.spec.to_json]
    end

  end
}

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