module Quickbooks::Config

  API_ROOT = File.join(File.dirname(__FILE__), '..', '..').freeze
  XML_SCHEMA_PATH = File.join(API_ROOT, 'xml_schema').freeze   
  RUBY_SCHEMA_PATH = File.join(API_ROOT, 'ruby_schema').freeze 

  SCHEMA_MAP = {
    :qb    => {:dtd_file => "qbxmlops70.xml", 
               :namespace => Quickbooks::QBXML, 
               :container_class => 'QBXML',
               :required_xml_attributes => {
                 "onError" => "stopOnError"
               }
              }.freeze,
    :qbpos => {:dtd_file => "qbposxmlops30.xml", 
               :namespace => Quickbooks::QBPOSXML, 
               :container_class => 'QBPOSXML',
               :required_xml_attributes => {
                 "onError" => "stopOnError"
               }
              }.freeze,
  }.freeze

  def self.included(klass)
    klass.extend ClassMethods
  end

private

  def container_class
    schema_namespace.const_get(SCHEMA_MAP[schema_type][:container_class])
  end

  def dtd_file
    "#{XML_SCHEMA_PATH}/#{SCHEMA_MAP[schema_type][:dtd_file]}" 
  end

  def schema_namespace
    SCHEMA_MAP[schema_type][:namespace]
  end

  def required_xml_attributes
    SCHEMA_MAP[schema_type][:required_xml_attributes]
  end


# introspection
  
  def cached_classes
    schema_namespace.constants.map { |const| schema_namespace.const_get(const) }
  end

module ClassMethods

  def check_schema_type!(schema_type)
    unless SCHEMA_MAP.include?(schema_type)
      raise(ArgumentError, "valid schema type required: #{valid_schema_types.inspect}") 
    end
  end

private

  def valid_schema_types
    SCHEMA_MAP.keys
  end

end


end
