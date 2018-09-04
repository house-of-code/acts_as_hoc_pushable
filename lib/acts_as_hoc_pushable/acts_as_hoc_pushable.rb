module ActsAsHocPushable
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    def acts_as_hoc_pushable(_options = {})
      has_many :devices, as: :parent, class_name: 'ActsAsHocPushable::Device', dependent: :destroy
    end
  end

  def active_devices
    devices.active
  end

  def ios_devices
    devices.ios
  end

  def android_devices
    devices.android
  end


  def add_device(token:, platform:, platform_version:, push_environment:)
    device = devices.new(token: token, platform: platform, platform_version: platform_version, push_environment: push_environment)
    return device if device.save
    device.errors.each do |attribute, message|
      errors.add(:devices, "#{attribute} #{message}")
    end
    nil
  end

  def add_device(device_params)
    device = devices.new(device_params)
    return device if device.save
    device.errors.each do |attribute, message|
      errors.add(:devices, "#{attribute} #{message}")
    end
    nil
  end

  def add_device!(device_params)
    device = devices.new(device_params)
    device.save!
    device
  end

  def send_push_notification(title:, message:, **data)
    ActsAsHocPushable::PushNotification.send_push_notification(devices: devices, title: title, message: message, **data)
  end

  def send_silent_push_notification(**data)
    ActsAsHocPushable::PushNotification.send_silent_push_notification(devices: devices, **data)
  end

end
ActiveRecord::Base.send :include, ActsAsHocPushable
