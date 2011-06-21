class Quickbooks::API
  include Quickbooks::Support
  include Quickbooks::Support::API
  include Quickbooks::Support::QBXML

attr_reader :dtd_parser, :qbxml_parser, :schema_type
@@instances = {}

def initialize(schema_type = nil, opts = {})
  @schema_type = schema_type
  use_disk_cache, log_level = opts.values_at(:use_disk_cache, :log_level)

  unless valid_schema_type?
    raise(ArgumentError, "schema type required: #{valid_schema_types.inspect}") 
  end

  @dtd_file = get_dtd_file
  @dtd_parser = DtdParser.new(schema_type)
  @qbxml_parser = QbxmlParser.new(schema_type)

  load_qb_classes(use_disk_cache)
  @@instances[schema_type] = self
end

# returns the last created api instance
def self.[](schema_type)
  @@instances[schema_type] || self.new(schema_type)
end

def container
  get_container_class
end

def qbxml_classes
  cached_classes
end

def find(class_name)
  class_name = class_name.to_s
  cached_classes.find { |c| to_attribute_name(c) == class_name }
end

def grep(pattern)
  case patthern
  when Regex
    cached_classes.select { |c| to_attribute_name(c).match(pattern) }
  when String
    cached_classes.select { |c| to_attribute_name(c).include?(pattern) }
  end
end

# QBXML 2 RUBY

def qbxml_to_obj(qbxml)
  case qbxml
  when IO
    qbxml_parser.parse_file(qbxml)
  else
    qbxml_parser.parse(qbxml)
  end
end

def qbxml_to_hash(qbxml, include_container = false)
  qb_obj = qbxml_to_obj(qbxml)
  unless include_container
    qb_obj.inner_attributes
  else
    qb_obj.attributes
  end
end


# RUBY 2 QBXML

def hash_to_obj(data)
  key = data.keys.first
  value = data[key]

  key_path = find_nested_key(container.template(true), key.to_s)
  raise(RuntimeError, "#{key} class not found in api template") unless key_path

  wrapped_data = build_hash_wrapper(key_path, value)
  container.new(wrapped_data)
end

def hash_to_qbxml(data)
  hash_to_obj(data).to_qbxml
end

# Disk Cache

def clear_disk_cache(rebuild = false)
  qbxml_cache = Dir["#{get_disk_cache_path}/*.rb"]
  template_cache = Dir["#{get_template_cache_path}/*.yml"]
  File.delete(*(qbxml_cache + template_cache))
  load_qb_classes(rebuild)
end


private 


def load_qb_classes(use_disk_cache = false)
  if use_disk_cache
    disk_cache = Dir["#{get_disk_cache_path}/*.rb"]
    if disk_cache.empty?
      log.info "Warning: on disk schema cache is empty, rebuilding..."
      rebuild_schema_cache(false, true)
    else
      disk_cache.each {|file| require file }
    end
  else
    rebuild_schema_cache(false, false)
  end

  # load the container class template into memory (significantly speeds up wrapping of partial data hashes)
  get_container_class.template(true, use_disk_cache, use_disk_cache)
  true
end

# rebuilds schema cache in memory and writes to disk if desired
#
def rebuild_schema_cache(force = false, write_to_disk = false)
  dtd_parser.parse_file(@dtd_file) if (cached_classes.empty? || force)
  dump_cached_classes if write_to_disk
end

# writes dynamically generated api classes to disk
#
def dump_cached_classes
  cached_classes.each do |c|  
    File.open("#{get_disk_cache_path}/#{to_attribute_name(c)}.rb", 'w') do |f|
      f << Ruby2Ruby.translate(c)
    end
  end
end

def self.log
  @@log ||= Logger.new(STDOUT, DEFAULT_LOG_LEVEL)
end


end
