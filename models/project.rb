require 'base64'

class Project < ActiveRecord::Base
  belongs_to :user

  def key
    Base64.strict_encode64(self[:name])
  end

  def self.find_by_key key
    project = self.where(:name => Base64.strict_decode64(key))
    return nil if !project.exists?
    return project.first
  rescue
    return nil
  end

  def to_h
    {key: self.key,
     description: self.description}
  end

end