require "support/memory_model"

module SampleObjects

  class User < MemoryModel

    field :first_name
    field :last_name
    field :age
    field :created_at, default: ->{ Time.now }
    field :updated_at, default: ->{ Time.now }

    has_many :posts
    has_many :comment

  end

  class Post < MemoryModel

    field :body
    field :created_at, default: ->{ Time.now }
    field :updated_at, default: ->{ Time.now }

    has_many :comments
    has_one :rating

  end

  class Comment < MemoryModel

    field :content
    field :created_at, default: ->{ Time.now }
    field :updated_at, default: ->{ Time.now }

    belongs_to :user


  end

  class Rating < MemoryModel

    field :stars, default: -> { Random.rand(1.0..5.0).round(1) }
    field :count, default: -> { Random.rand(20..100) }

    accepts_nested_attributes_for :post

    belongs_to :post

  end

end