module Quickbooks::Support::API
  include Quickbooks

  API_ROOT = File.join(File.dirname(__FILE__), '..', '..', '..').freeze
  XML_SCHEMA_PATH = File.join(API_ROOT, 'xml_schema').freeze   
  RUBY_SCHEMA_PATH = File.join(API_ROOT, 'ruby_schema').freeze 

  SCHEMA_MAP = {
    :qb    => {:dtd_file => "qbxmlops70.xml", 
               :namespace => QBXML, 
               :container_class => lambda { Quickbooks::QBXML::QBXML },
               :required_xml_attributes => {
                 "onError" => "stopOnError"
               }
              }.freeze,
    :qbpos => {:dtd_file => "qbposxmlops30.xml", 
               :namespace => QBPOSXML, 
               :container_class => lambda { Quickbooks::QBPOSXML::QBPOSXML },
               :required_xml_attributes => {
                 "onError" => "stopOnError"
               }
              }.freeze,
  }.freeze

  DEFAULT_LOG_LEVEL = 1

private

  def valid_schema_types
    SCHEMA_MAP.keys
  end

  def valid_schema_type?
    SCHEMA_MAP.include?(schema_type)
  end

  def get_dtd_file
    "#{XML_SCHEMA_PATH}/#{SCHEMA_MAP[schema_type][:dtd_file]}" 
  end

  def get_schema_namespace
    SCHEMA_MAP[schema_type][:namespace]
  end

  def get_container_class
    SCHEMA_MAP[schema_type][:container_class].call
  end

  def get_disk_cache_path
    "#{RUBY_SCHEMA_PATH}/#{schema_type.to_s}"
  end

  def get_template_cache_path
    "#{RUBY_SCHEMA_PATH}/#{schema_type.to_s}/templates"
  end

  def get_required_xml_attributes
    SCHEMA_MAP[schema_type][:required_xml_attributes]
  end

  # fetches all the dynamically generated schema classes
  def cached_classes
    cached_classes = SCHEMA_MAP.inject({}) do |h, (schema_type, opts)|
      namespace = opts[:namespace]
      h[schema_type] = namespace.constants.map { |klass| namespace.const_get(klass) }; h
    end
    cached_classes[schema_type]
  end

  def is_cached_class?(klass)
    SCHEMA_MAP.any? do |schema_type, opts|
      namespace = opts[:namespace]
      namespace.constants.include?(simple_class_name(klass))
    end
  end

  def find_nested_key(hash, key)
    hash.each do |k,v|
      path = [k]
      if k == key
        return path
      elsif v.is_a? Hash
        nested_val = find_nested_key(v, key)
        nested_val ? (return path + nested_val) : nil
      end
    end
    return nil
  end

  def build_hash_wrapper(path, value)
    hash_constructor = lambda { |h, k| h[k] = Hash.new(&hash_constructor) }

    wrapped_data = Hash.new(&hash_constructor)
    path.inject(wrapped_data) { |h, k| k == path.last ? h[k] = value: h[k] }
    wrapped_data
  end

end
