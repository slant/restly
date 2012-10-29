class Restly::Proxies::WithPath < Restly::Proxies::Base

  def initialize(receiver, *args)
    super(receiver)
    @options = args.extract_options!
    @options.assert_valid_keys(:prepend, :append)
    self.path = args.first
    adjust_path_from_options! if @options.present?
  end

  def adjust_path_from_options!
    prepend = if @options[:prepend]
                @options[:prepend].gsub(/^([^\/])/, "/\\1").gsub(/\/$/, "")
              end

    append = if @options[:append]
                @options[:append].gsub(/^\//, "").gsub(/\/$/, "")
              end

    self.path = [prepend, path, append].compact.join('/')

  end

end