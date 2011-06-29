require 'buffered_logger'

module Quickbooks::Logger
  def log
    Quickbooks::Log.log
  end
end

class Quickbooks::Log
  private_class_method :new
  LOG_LEVEL = 1

  def self.init(log_level)
    @log = BufferedLogger.new(STDOUT, log_level || LOG_LEVEL)
  end

  def self.log
    @log ||= BufferedLogger.new(STDOUT, LOG_LEVEL)
  end
end
