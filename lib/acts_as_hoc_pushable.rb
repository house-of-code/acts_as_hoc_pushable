require 'acts_as_hoc_pushable/version'
require 'acts_as_hoc_pushable/acts_as_hoc_pushable'
require 'acts_as_hoc_pushable/configuration'
require 'acts_as_hoc_pushable/push_notification'
require 'acts_as_hoc_pushable/active_record/device.rb'

module ActsAsHocPushable
  LOCK = Mutex.new
  class << self
    def configure(config_hash=nil)
      if config_hash
        config_hash.each do |k,v|
          configuration.send("#{k}=", v) rescue nil if configuration.respond_to?("#{k}=")
        end
      end

      yield(configuration) if block_given?
    end

    def configuration
      @configuration = nil unless defined?(@configuration)
      @configuration || LOCK.synchronize { @configuration ||= ActsAsHocPushable::Configuration.new }
    end
  end
end
