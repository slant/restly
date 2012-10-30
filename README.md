# Restly

Restly is an ActiveModel based ODM (Object Document Mapper) for restful web-services. It includes the ability to define relationships to any Ruby class using some built in helpers.

## Installation

Add this line to your application's Gemfile:

    gem 'restly'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install restly

## Configuration
In order for restly to funciton it will need some configuration. This can be done by placing restly.yml in your config directory. We have added a generator to make this easier.

```sh
$ rails generate restly:configuration
```

This will generate a file like so:

```yaml
development:
  site: http://example.com # Change This
  default_format: json # defaults to: json

  ## Cache Requests?
  # cache: true
  # cache_options:
  #   expires_in: 3600

  ## If you are using oauth:
  # use_oauth: true
  # oauth_options:
  #   client_id: 98f7901322970fb0c40229dfc8f5a1a5
  #   client_secret: 5331b2a8d5dc2cf0aa692bc3a39ac789

test:
  site: http://example.com # Change This
  default_format: json # defaults to: json

  ## If you are using oauth:
  # use_oauth: true
  # oauth_options:
  #   client_id: 98f7901322970fb0c40229dfc8f5a1a5
  #   client_secret: 5331b2a8d5dc2cf0aa692bc3a39ac789

production:
  site: http://example.com # Change This
  default_format: json # defaults to: json

  ## Cache Requests?
  cache: true
  cache_options:
    expires_in: 3600

  ## If you are using oauth:
  # use_oauth: true
  # oauth_options:
  #   client_id: 98f7901322970fb0c40229dfc8f5a1a5
  #   client_secret: 5331b2a8d5dc2cf0aa692bc3a39ac789

```

## Creating a Restly Model

# Using the generator

```
$ rails generate restly:model MyModel
```

This will generate a model that looks like this:

```ruby
class MyModel < Restly::Base

  # self.resource_name = 'my_model'
  # self.path = 'some_path/to_resource' # defaults to: 'resource_name.pluralized'

end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
