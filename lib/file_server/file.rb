module FileServer

  class File < ReactiveResource::Base

    self.format = :json
    self.site = "http://localhost:1234/"

    def self.download path
      self.get "download", path: path
    end

  end

end