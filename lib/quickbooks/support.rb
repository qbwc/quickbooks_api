# namespace for dynamically gnerated schema classes
module Quickbooks::QBXML; end
module Quickbooks::QBPOSXML; end

module Quickbooks::Support

  def to_attribute_name(obj)
    name = \
      case obj
      when Class
        simple_class_name(obj)
      when Nokogiri::XML::Element
        obj.name
      else
        obj.to_s
      end
    inflector.underscore(name)
  end

  def simple_class_name(klass)
    klass.to_s.split("::").last
  end

  # easily convert between CamelCase and under_score
  def inflector
    ActiveSupport::Inflector
  end

  def log
    Quickbooks::API.log
  end

end
