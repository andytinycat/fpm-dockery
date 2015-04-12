require "clamp"
require "logger"
require "open3"

require "fpm/dockery/version"
require "fpm/dockery/logging"
require "fpm/dockery/utils"
require "fpm/dockery/cli"

module FPM
  module Dockery
    def self.root
      File.expand_path("../../../", __FILE__)
    end
  end
end
