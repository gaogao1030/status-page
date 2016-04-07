module StatusPage
  class Configuration
    PROVIDERS = [:cache, :database, :redis, :resque, :sidekiq].freeze

    attr_accessor :error_callback, :basic_auth_credentials
    attr_reader :providers

    def initialize
      @providers = Set.new
    end

    def use(provider_name)
      require "status-page/services/#{provider_name}"
      add_provider("StatusPage::Services::#{provider_name.capitalize}".constantize)
    end

    PROVIDERS.each do |provider_name|
      define_method provider_name do |&_block|
        require "status-page/services/#{provider_name}"

        add_provider("StatusPage::Services::#{provider_name.capitalize}".constantize)
      end
    end

    def add_custom_provider(custom_provider_class)
      unless custom_provider_class < StatusPage::Services::Base
        raise ArgumentError.new 'custom provider class must implement '\
          'StatusPage::Services::Base'
      end

      add_provider(custom_provider_class)
    end

    private

    def add_provider(provider_class)
      (@providers ||= Set.new) << provider_class

      provider_class
    end
  end
end