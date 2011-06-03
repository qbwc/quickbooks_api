require 'forwardable'

class Quickbooks::Support::Logger
  extend Forwardable

  def_delegators :@logger, :level, :flush, :auto_flushing=

  DEFAULT_FORMATTER = "%s"
  DEFAULT_PADDING = ""
  PADDING_CHAR = " "

  def initialize(log_file, log_level, log_count = nil, log_size = nil)
    @logger = ActiveSupport::BufferedLogger.new(log_file, log_level)
    @padding, @formatter = {}, {}
  end

  def buffer
    buf = @logger.send(:buffer)
    buf && buf.join('')
  end

  # overwrite all the logging methods
  class_eval do
    [:debug, :info, :warn, :error, :fatal, :unknown].each do |method|
      define_method(method) do |message|
        @logger.send(method, (padding + formatter) % message.to_s)
      end
    end
  end

  def indent(indent_level)
    @padding[Thread.current] = \
      if indent_level == :reset
        ""
      elsif indent_level > 0
        padding + (PADDING_CHAR * indent_level)
      else
        padding[0..(-1+indent_level)]
      end
  end

  def formatter=(format)
    @formatter[Thread.current] = format
  end

protected

  def padding
    @padding[Thread.current] ||= DEFAULT_PADDING
  end
  
  def formatter
    @formatter[Thread.current] ||= DEFAULT_FORMATTER
  end

end
