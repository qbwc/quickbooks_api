module Quickbooks::Support
  include Quickbooks

  # universal
  #
  API_ROOT = File.join(File.dirname(__FILE__), '..', '..')


  # parser support
  #
  XML_DOCUMENT = Nokogiri::XML::Document
  XML_NODE_SET = Nokogiri::XML::NodeSet
  XML_NODE = Nokogiri::XML::Node
  XML_ELEMENT = Nokogiri::XML::Element
  XML_COMMENT= Nokogiri::XML::Comment
  XML_TEXT = Nokogiri::XML::Text

  def is_leaf_node?(xml_obj)
    xml_obj.children.size == 1 && xml_obj.children.first.class == XML_TEXT
  end

  def to_attribute_name(obj)
    name = \
      if obj.is_a? Class
        simple_class_name(obj)
      elsif obj.is_a? XML_ELEMENT
        obj.name
      else
        obj.to_s
      end
    inflector.underscore(name)
  end

  def cached_classes
    classes = Qbxml.constants.map { |klass| Qbxml.const_get(klass) }
    classes.reject { |klass| klass == Quickbooks::Qbxml::Base }
  end
  
  def simple_class_name(klass)
    klass.name.split("::").last
  end

  def inflector
    ActiveSupport::Inflector
  end

  def log
    @log ||= Logger.new(STDOUT, API::LOG_LEVEL)
  end

end
