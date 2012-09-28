module OauthResource::ThreadLocal
  def thread_local_accessor(*names)
    names.each do |name|
      class_variable_set :"@@#{name}", {}
      accessor = class_variable_get("@@#{name}")

      # Thread Accessor Getter
      define_singleton_method name do
        thread_id = Thread.current.object_id
        accessor[thread_id]
      end

      # Thread Accessor Setter
      define_singleton_method "#{name}=" do |val|
        thread_id = Thread.current.object_id
        finalizer = ->(id){ class_variable_get("@@#{name}").delete(id) }
        ObjectSpace.define_finalizer Thread.current, finalizer unless accessor.has_key? thread_id
        accessor[thread_id] = val
      end

    end
  end
end
