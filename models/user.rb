class User < ActiveRecord::Base
  has_many :devices
  has_secure_password

  def find_or_create_device device_code, device_name="unknown"
    return self.devices.where(device_code: device_code).first if self.devices.where(device_code: device_code).exists?

    return self.devices.create(device_name: device_name, device_code: device_code)
	end

  def self.allow? user_name, device_code
    user = User.find_by_user_name(user_name)

    return false unless user && user.devices.find_by_device_code(device_code)

    return true
  end

end