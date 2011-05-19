module Quickbooks::Support
  include Quickbooks

  API_ROOT = File.join(File.dirname(__FILE__), '..', '..').freeze
  DEFAULT_LOG_LEVEL = 1

  # fetches all the dynamically generated schema classes
  def cached_classes
    classes = Qbxml.constants.map { |klass| Qbxml.const_get(klass) }
    classes.reject { |klass| klass == Quickbooks::Qbxml::Base }
  end
  
  # easily convert between CamelCase and under_score
  def inflector
    ActiveSupport::Inflector
  end

  def log(reload = false, log_level = DEFAULT_LOG_LEVEL)
    @@log = (!reload && @@log) || Logger.new(STDOUT, log_level)
  end

end
