module Restly::ThreadLocal

  private

  def thread_local_accessor(*names)
    names.each do |name|
      class_variable_set :"@@#{name}", {}

      define_thread_getter(name)
      define_thread_setter(name)

    end
  end

  def define_thread_getter(name)
    accessor = class_variable_get("@@#{name}")
    define_singleton_method name do
      thread_id = Thread.current.object_id
      accessor[thread_id]
    end
  end

  def define_thread_setter(name)
    accessor = class_variable_get("@@#{name}")
    define_singleton_method "#{name}=" do |val|
      thread_id = Thread.current.object_id
      finalizer = ->(id){ class_variable_get("@@#{name}").delete(id) }
      ObjectSpace.define_finalizer Thread.current, finalizer unless accessor.has_key? thread_id
      accessor[thread_id] = val
    end
  end

end
