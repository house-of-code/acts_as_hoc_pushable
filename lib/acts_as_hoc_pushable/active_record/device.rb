module ActsAsHocPushable
  class Device < ActiveRecord::Base
    belongs_to :parent, polymorphic: true

    validates :token, :platform, :valid_at, :parent, :platform_version, :push_environment, presence: true
    validates :token, uniqueness: true
    validates :active, inclusion: { in: [true, false] }

    before_validation :set_valid_at, on: :create
    before_validation :strip_spaces_from_token, on: :create, if: :token

    scope :active, -> { where(invalidated_at: nil, active: true) }
    scope :ios, -> { where(platform: "ios") }
    scope :android, -> { where(platform: "android") }

    default_scope { active }

    def ios?
      platform == 'ios'
    end

    def android?
      platform == 'android'
    end

    def invalidate
      update_attributes(invalidated_at: Time.current)
    end

    def deactivate
      update_attributes(active: false, deactivated_at: Time.current)
    end

    def send_notification(title:, message:, **data)
      ActsAsHocPushable::PushNotification.send_push_notification(devices: [self], title: title, message: message, **data)
    end

    def send_silent_notification(**data)
      ActsAsHocPushable::PushNotification.send_silent_push_notification(devices: [self], **data)
    end

    private

    def set_valid_at
      self.valid_at = Time.current
    end

    def strip_spaces_from_token
      self.token = token.delete(' ')
    end
  end
end
