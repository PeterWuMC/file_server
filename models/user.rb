require 'digest/sha1'


class User < ActiveRecord::Base
  has_many :devices, :dependent => :destroy
  has_many :projects, :dependent => :destroy

  has_secure_password
  validates_uniqueness_of :user_name
  validate :validate_user_name

  after_create :create_initial_projects_and_folder
  after_destroy :remove_private_data

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

  private
    def create_initial_projects_and_folder
      self.projects.create(name: "public", description: "shared folder")
      self.projects.create(name: self.user_name, description: "private folder")
      Dir::mkdir("#{server_path}/#{self.user_name}")
    end

    def validate_user_name
      errors.add(:user_name, "cannot contain non-word characters") if self.user_name =~ /\W/
    end

    def remove_private_data
      FileUtils.rm_rf("#{server_path}/#{self.user_name}")
    end
end