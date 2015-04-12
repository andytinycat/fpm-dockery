module FPM
  module Dockery
    module Logging
      
      @@logger = Logger.new(STDOUT)
      @@logger.formatter = proc do |severity, datetime, progname, msg|
        "[#{severity}] #{msg}\n"
      end
      
      def info(msg)
        @@logger.info(msg)
      end
      
      def warn(msg)
        @@logger.warn(msg)
      end
      
      def fatal(msg)
        @@logger.fatal(msg)
      end
      
    end
  end
end