require "support/memory_model"

module SampleObjects

  class User < MemoryModel

    field :first_name
    field :last_name
    field :age
    field :created_at, default: ->{ Time.now }
    field :updated_at, default: ->{ Time.now }

  end

  class Post < MemoryModel

    field :body
    field :created_at, default: ->{ Time.now }
    field :updated_at, default: ->{ Time.now }

  end

end