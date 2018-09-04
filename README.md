# ActsAsHocPushable

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/acts_as_hoc_pushable`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'acts_as_hoc_pushable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install acts_as_hoc_pushable

## Usage

### Make application ready for acts_as_hoc_pushable
Install by running:

    $ rails generate acts_as_hoc_pushable:install

This will create, models, migrations and initializer

### Extend model
Add the `acts_as_hoc_pushable` to the model you want to be extended with push functionallity - eg. user.

```ruby
#app/models/user.rb
class User < ApplicationRecord
  acts_as_hoc_pushable
end
```

now you have the following functionallity added to the model

* Add a device to an user
  `user.add_device(token:, platform:, platform_version:, push_environment:)`
  `user.add_device(params)`
  `user.add_device!(params)`
* Get active devices
  `user.active_devices`
* Get platform specific devices
  `user.ios_devices`
  `user.android_devices`
* Send push notification
  `user.send_push_notification(title:, message:, **data)`
* Send silent push notification
  `send_silent_push_notification(**data)`


### Other functions

#### Send to topic:
You can send push notifications to a topic with:
```ruby
  ActsAsHocPushable::PushNotification.send_push_notification_to_topic(topic:, title: nil, message: nil, **data)
```
or for silent notification:
```ruby
  ActsAsHocPushable::PushNotification.send_silent_push_notification_to_topic(topic:, **data)
```
#### Send to many devices:
```ruby
  ActsAsHocPushable::PushNotification.send_push_notification(devices:, title: nil, message: nil, **data)
```
or for silent notification:
```ruby
  ActsAsHocPushable::PushNotification.send_silent_push_notification(devices:, **data)
```


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
