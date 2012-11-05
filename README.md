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
development: &development
  site: http://example.com # Change This
  default_format: json # defaults to: json

  ## Would you like requests to be cached?
  # cache: true
  # cache_options:
  #   expires_in: 3600

  ## Enable Oauth?
  # use_oauth: true
  # oauth_options:
  #   client_id: %client_id%
  #   client_secret: %client_secret%

test:
  <<: *development

production:
  site: http://example.com # Change This
  default_format: json # defaults to: json

  # Would you like requests to be cached?
  cache: true
  cache_options:
     expires_in: 3600

  ## Enable Oauth?
  # use_oauth: true
  # oauth_options:
  #   client_id: %client_id%
  #   client_secret: %client_secret%

```

=======
*__Restly ships with OAuth2 support, allowing you to authorize requests before making them.__*

## Creating a Restly Model

### Using the generator

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
=======
Generates:

```
class MyModel < Restly::Base

    field :id # implied
    field :my_attr

end
```

## Interacting With Objects

In restly interacting with objects is familiar.

__Getting the Collection:__

```ruby
MyModel.all
```

__Finding an Instance:__

```ruby
my_instance = MyModel.find(1)
```

__Updating an Instance:__

```ruby
my_instance.update_attributes({my_attr: 'val'})
```

or

```ruby
my_instance.my_attr = 'val'
my_instance.save
```

__Creating an Instance__

```
my_instance
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
