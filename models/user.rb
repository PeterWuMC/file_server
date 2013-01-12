require 'digest/sha1'

class User < ActiveRecord::Base
  has_many :devices
  has_many :projects
  has_secure_password

  def find_or_create_device device_code, device_name="unknown"
    puts device_code
    encrypted_device_code = Digest::SHA1.hexdigest(device_code + secret_key)
    return self.devices.where(device_code: encrypted_device_code).first if self.devices.where(device_code: encrypted_device_code).exists?

    return self.devices.create(device_name: device_name, device_code: encrypted_device_code)
	end

  def self.allow? user_name, device_code
    user = User.find_by_user_name(user_name)

    return nil unless user && user.devices.find_by_device_code(device_code)

    return user
  end

end