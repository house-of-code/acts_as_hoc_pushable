require 'json'
require 'fcm'
module ActsAsHocPushable
  class PushNotification

    attr_accessor :devices, :title, :message, :data

    def initialize(devices:, title:, message:, **data)
      @devices = devices
      @title = title
      @message = message
      @data = data
    end

    def self.send_push_notification_to_topic(topic:, title: nil, message: nil, **data)
      new(devices: nil, title: title, message: message, **data).perform_topic(topic: topic)
    end

    def self.send_silent_push_notification_to_topic(topic:, **data)
      silent_data = data.merge({ content_avaiable: true })
      new(devices: nil, title: nil, message: nil, **silent_data).perform_topic(topic: topic)
    end

    def self.send_push_notification(devices:, title: nil, message: nil, **data)
      new(devices: devices, title: title, message: message, **data).perform
    end

    def self.send_silent_push_notification(devices:, **data)
      silent_data = data.merge({ content_avaiable: true })
      new(devices: devices, title: nil, message: nil, **silent_data).perform
    end

    def perform_topic(topic:)
      response = client.send_to_topic(topic, push_options)
      handle_response(response)
    end

    def perform
      tokens = @devices.map {|d| d.token }
      response = client.send(tokens, push_options)
      handle_response(response)
    end

    protected

    def title
      @title ||= ""
    end

    def push_options(options = {})
      options = {
        priority: 'high',
        data: data
      }.merge(options)
      options[:notification] = { body: @message, title: title } unless @message.nil?
      options
    end

    private

    def client
      FCM.new(ActsAsHocPushable.configuration.firebase_key)
    end



    # Handles the response from firebase. Invalidates failed tokens
    def handle_response(response)
      Rails.logger.info "Raw response from fcm: #{response}" if (ActsAsHocPushable.configuration.debug_firebase_response ||= false)
      body = parse_json(response[:body])
      return if body.nil?
      Rails.logger.info "Parsed response from fcm: #{body}" if (ActsAsHocPushable.configuration.debug_firebase_response ||= false)
      failure = body['failure'].to_i
      if failure > 0
        i = 1
        results = body['results']
        results.each do |r|
          invalidate_token_at_pos(i) if r.has_key? 'error'
          i += 1
        end
      end
    end

    def parse_json(json)
      JSON.parse(json) rescue nil if json && json.length >= 2
    end

    def invalidate_token_at_pos(pos)
      @devices.first(pos).last.invalidate if pos <= @devices.count
    end
  end
end
