class Class

  private

  # Sets Unique Variables on a resource
  def rattr_accessor(*attrs)
    attrs.each do |attr|

      # Setter defining getter
      define_singleton_method :"#{attr}=" do |value|
        define_singleton_method attr do
          value
        end
      end

      # Default Nil Getter
      define_singleton_method attr do
        nil
      end

    end
  end

end